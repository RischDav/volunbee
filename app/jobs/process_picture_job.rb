require 'mini_magick'

class ProcessPictureJob < ApplicationJob
  queue_as :default

  def perform(picture_id)
    picture = ActiveStorage::Attachment.find(picture_id)
    image = MiniMagick::Image.read(picture.download)
    
    image.combine_options do |c|
      c.resize "700x700^"
      c.gravity "center"
      c.crop "700x700+0+0"
    end
    
    image.strip

    tempfile = Tempfile.new(["processed", ".jpg"])
    image.write(tempfile.path)
    picture.blob.upload(tempfile)
    tempfile.close
    tempfile.unlink
  end
end