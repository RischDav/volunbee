class AnalyticsController < ApplicationController
	before_action :authenticate_user!
	before_action :ensure_university_staff!

	def index
		@university = current_user.university
		unless @university
			redirect_to(root_path, alert: "Keine Universität zugeordnet.") and return
		end

		student_events = UserEvent.where(user_type: :student, university_id: @university.id)
		earliest_event_date = student_events.minimum(:created_at)&.to_date
		latest_event_date = student_events.maximum(:created_at)&.to_date

		@available_start = earliest_event_date || (Date.today - 6.days)
		@available_end = latest_event_date || Date.today

		@start_date, @end_date = extract_range(params[:start_date], params[:end_date], @available_start, @available_end)
		@date_range = (@start_date..@end_date).to_a
		@range_days_count = @date_range.size

		events_in_range = student_events.where(created_at: @start_date.beginning_of_day..@end_date.end_of_day)
		counts_by_type = events_in_range.group(:action_type).group(Arel.sql("DATE(created_at)"))
		counts_by_type = counts_by_type.count.transform_keys do |(action_type, date)|
			normalized_date = date.is_a?(Date) ? date : Date.parse(date.to_s)
			[action_type.to_s, normalized_date]
		end

		@registration_series = build_event_series(counts_by_type, :sign_up)
		@contact_request_series = build_event_series(counts_by_type, :contacted_organization)
		@activity_series = build_event_series(counts_by_type, [:logged_in, :view_position])

		@registration_total = total_count(@registration_series)
		@contact_request_total = total_count(@contact_request_series)
		@activity_total = total_count(@activity_series)

		@registration_peak = peak_value(@registration_series)
		@contact_request_peak = peak_value(@contact_request_series)
		@activity_peak = peak_value(@activity_series)

		@table_data = build_table_data
	end

	private

	def ensure_university_staff!
		return if current_user&.university_staff?

		redirect_to(root_path, alert: "Du hast keinen Zugriff auf das Analytics-Dashboard.")
	end

	def extract_range(start_param, end_param, min_date, max_date)
		default_end = max_date
		default_start = [max_date - 6.days, min_date].max

		start_date = parse_date(start_param) || default_start
		end_date = parse_date(end_param) || default_end

		if start_date > end_date
			start_date, end_date = end_date, start_date
		end

		start_date = start_date.clamp(min_date, max_date)
		end_date = end_date.clamp(min_date, max_date)
		start_date = [start_date, end_date].min

		[start_date, end_date]
	end

	def parse_date(value)
		return if value.blank?

		Date.parse(value)
	rescue ArgumentError
		nil
	end

	def total_count(series)
		series.sum { |data_point| data_point[:count] }
	end

	def peak_value(series)
		[series.map { |data_point| data_point[:count] }.max || 0, 1].max
	end

	def build_event_series(counts_by_type, action_types)
		type_keys = Array(action_types).map(&:to_s)

		@date_range.map do |date|
			count = type_keys.sum { |type_key| counts_by_type[[type_key, date]] || 0 }
			{
				date: date,
				label: I18n.l(date, format: :short),
				count: count
			}
		end
	end

	def build_table_data
		registrations_by_date = @registration_series.index_by { |dp| dp[:date] }
		contact_requests_by_date = @contact_request_series.index_by { |dp| dp[:date] }
		activity_by_date = @activity_series.index_by { |dp| dp[:date] }

		@date_range.map do |date|
			{
				label: I18n.l(date, format: :short),
				registrations: registrations_by_date[date] ? registrations_by_date[date][:count] : 0,
				contact_requests: contact_requests_by_date[date] ? contact_requests_by_date[date][:count] : 0,
				activity: activity_by_date[date] ? activity_by_date[date][:count] : 0
			}
		end.reverse
	end

end
