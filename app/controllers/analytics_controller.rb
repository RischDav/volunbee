class AnalyticsController < ApplicationController
	before_action :authenticate_user!
	before_action :ensure_university_staff!

	AVAILABLE_DATA = {
		registrations: [5, 7, 6, 8, 9, 10, 8, 7, 9, 12, 11, 10, 13, 15, 14, 12, 13, 16, 18, 17, 14, 13, 15, 19, 21, 18, 17, 20, 22, 24],
		contact_requests: [2, 3, 3, 4, 5, 4, 3, 4, 5, 6, 5, 5, 6, 7, 6, 5, 6, 7, 8, 8, 6, 5, 7, 9, 10, 9, 8, 9, 10, 11],
		activity: [12, 15, 14, 16, 18, 20, 19, 18, 21, 24, 22, 23, 25, 27, 26, 24, 25, 28, 30, 29, 27, 26, 28, 31, 33, 32, 30, 34, 35, 36]
	}.freeze

	FACULTY_SEGMENTS = [
		{ label: "Informatik & Data Science", count: 86, color: "#0f766e" },
		{ label: "Wirtschaft & Management", count: 64, color: "#14b8a6" },
		{ label: "Design & Medien", count: 41, color: "#2dd4bf" },
		{ label: "Soziale Arbeit", count: 33, color: "#5eead4" }
	].freeze

	CONVERSION_FUNNEL_STEPS = [
		{ label: "Profilaufrufe", count: 520 },
		{ label: "Kontaktaufnahmen", count: 210 },
		{ label: "Erstgespräche", count: 124 },
		{ label: "Verbindliche Zusagen", count: 58 }
	].freeze

	SERIES_LENGTH = AVAILABLE_DATA[:registrations].length

	def index
		seeded_series = seed_series
		@available_start = seeded_series[:registrations].first[:date]
		@available_end = seeded_series[:registrations].last[:date]

		@start_date, @end_date = extract_range(params[:start_date], params[:end_date], @available_start, @available_end)
		@date_range = (@start_date..@end_date).to_a
		@range_days_count = @date_range.size

		@registration_series = filter_series(seeded_series[:registrations], @start_date, @end_date)
		@contact_request_series = filter_series(seeded_series[:contact_requests], @start_date, @end_date)
		@activity_series = filter_series(seeded_series[:activity], @start_date, @end_date)

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

	def seed_series
		base_start_date = Time.zone.today - (SERIES_LENGTH - 1).days

		{
			registrations: build_series(AVAILABLE_DATA[:registrations], start_date: base_start_date),
			contact_requests: build_series(AVAILABLE_DATA[:contact_requests], start_date: base_start_date),
			activity: build_series(AVAILABLE_DATA[:activity], start_date: base_start_date)
		}
	end

	def build_series(counts, start_date: nil)
		start_date ||= Time.zone.today - (counts.size - 1).days

		counts.each_with_index.map do |count, index|
			date = start_date + index.days
			{
				date: date,
				label: I18n.l(date, format: :short),
				count: count
			}
		end
	end

	def filter_series(series, start_date, end_date)
		series.select { |data_point| data_point[:date].between?(start_date, end_date) }
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
