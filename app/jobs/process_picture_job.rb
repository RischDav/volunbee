class ProcessPictureJob < ApplicationJob
  queue_as :default

  def perform(picture)
    image = MiniMagick::Image.read(picture.download)
    image.resize "x400>" # Skaliert die Höhe auf maximal 500 Pixel, behält das Seitenverhältnis bei
    tempfile = Tempfile.new([ "processed", ".jpg" ])
    image.write(tempfile.path)
    picture.blob.upload(tempfile)
    tempfile.close
    tempfile.unlink
  end
end
