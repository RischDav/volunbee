class ShowPositionsController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index, :show]
  layout 'volunteer'
  
  def index
    @positions = Position.with_attached_main_picture
                         .with_attached_picture1
                         .with_attached_picture2
                         .with_attached_picture3
                         .where(online: true, released: true)

    @positions.each do |position|
      if position.main_picture.attached?
        begin
          url = Rails.application.routes.url_helpers.rails_blob_url(position.main_picture, only_path: true)
          Rails.logger.debug "Main picture URL for '#{position.title}': #{url}"
        rescue ActiveStorage::FileNotFoundError
          Rails.logger.debug "Missing file for '#{position.title}', purging attachment."
          position.main_picture.purge
        end
      else
        Rails.logger.debug "No main picture for '#{position.title}'"
      end
    end
  end

  def show
    @position = Position.find(params[:id])
    unless @position.online && @position.released
      render plain: "Position not found", status: :not_found
    end
  end

  # Run in rails console
  def self.purge_missing_files
    Position.find_each do |position|
      if position.main_picture.attached?
        begin
          position.main_picture.blob.open # Try to open the file
        rescue ActiveStorage::FileNotFoundError
          puts "Purging missing file for #{position.title}"
          position.main_picture.purge
        end
      end
      # Repeat for other pictures if needed:
      [:picture1, :picture2, :picture3].each do |pic|
        if position.send(pic).attached?
          begin
            position.send(pic).blob.open
          rescue ActiveStorage::FileNotFoundError
            puts "Purging missing file for #{position.title} (#{pic})"
            position.send(pic).purge
          end
        end
      end
    end
  end

  private

  def safe_main_picture_url
    if main_picture.attached?
      begin
        Rails.application.routes.url_helpers.rails_blob_url(main_picture, only_path: true)
      rescue ActiveStorage::FileNotFoundError
        nil
      end
    end
  end
end