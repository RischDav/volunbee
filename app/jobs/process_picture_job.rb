require 'vips'

class ProcessPictureJob < ApplicationJob
  queue_as :default

  def perform(picture_id)
    picture = ActiveStorage::Attachment.find(picture_id)
    
    # Process the main image
    image = Vips::Image.new_from_buffer(picture.download, "")
    image = image.resize(700.0 / image.width) if image.width > 700
    
    # Save the processed image
    tempfile = Tempfile.new(["processed", ".jpg"])
    image.write_to_file(tempfile.path, Q: 80)
    picture.blob.upload(tempfile)
    tempfile.close
    tempfile.unlink

    # Process variants
    begin
      # Process the gallery variant
      picture.variant(resize_to_fill: [600, 250]).processed
      # Process the logo variant
      picture.variant(resize_to_fill: [112, 112]).processed
    rescue => e
      Rails.logger.error "Error processing variants for picture #{picture_id}: #{e.message}"
    end
  end
end