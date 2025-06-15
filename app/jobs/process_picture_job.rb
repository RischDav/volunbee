class ProcessPictureJob < ApplicationJob
  queue_as :default

  def perform(picture_id)
    begin
      blob = ActiveStorage::Blob.find(picture_id)
      return unless blob
      
      # Lade das Bild und verarbeite es
      image = Vips::Image.new_from_buffer(blob.download, "")
      
      # Nur verkleinern, wenn das Bild zu breit ist
      if image.width > 1200
        image = image.resize(1200.0 / image.width)
      end
      
      # Erstelle eine temporäre Datei für das verarbeitete Bild
      tempfile = Tempfile.new(["processed", ".jpg"])
      image.write_to_file(tempfile.path, Q: 85)
      
      # Erstelle einen neuen Blob mit dem verarbeiteten Bild
      processed_blob = ActiveStorage::Blob.create_and_upload!(
        io: File.open(tempfile.path),
        filename: blob.filename,
        content_type: "image/jpeg"
      )
      
      # Finde das Attachment und ersetze den Blob
      attachment = ActiveStorage::Attachment.find_by(blob_id: blob.id)
      if attachment
        attachment.update!(blob: processed_blob)
        blob.purge # Lösche den alten Blob
      end
      
      tempfile.close
      tempfile.unlink
      
      # Erstelle Varianten im Hintergrund
      create_variants(processed_blob)
      
      Rails.logger.info "Successfully processed image #{picture_id}"
    rescue => e
      Rails.logger.error "Error processing picture #{picture_id}: #{e.message}"
    end
  end

  private

  def create_variants(blob)
    begin
      # Finde das Attachment für diesen Blob
      attachment = ActiveStorage::Attachment.find_by(blob: blob)
      return unless attachment
      
      # Erstelle verschiedene Varianten
      attachment.variant(resize_to_limit: [400, 250]).processed   # Thumbnails
      attachment.variant(resize_to_fill: [600, 250]).processed    # Galerie
      attachment.variant(resize_to_fill: [112, 112]).processed    # Logo/kleine Ansicht
      
      Rails.logger.info "Created variants for blob #{blob.id}"
    rescue => e
      Rails.logger.error "Error creating variants for blob #{blob.id}: #{e.message}"
    end
  end
end