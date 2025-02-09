require 'mini_magick'

class ProcessPictureJob < ApplicationJob
  queue_as :default

  def perform(picture)
    image = MiniMagick::Image.read(picture.download)
    image.resize "x700>" # Skaliert die Höhe auf maximal 100 Pixel, behält das Seitenverhältnis bei
    image.strip
    tempfile = Tempfile.new([ "processed", ".jpg" ])
    image.write(tempfile.path)
    picture.blob.upload(tempfile)
    tempfile.close
    tempfile.unlink
  end
end