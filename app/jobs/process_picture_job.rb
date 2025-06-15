class ProcessPictureJob < ApplicationJob
  queue_as :default
  retry_on StandardError, wait: 5.seconds, attempts: 3

  def perform(picture_id)
    begin
      blob = ActiveStorage::Blob.find(picture_id)
      return unless blob

      # Prüfe ob Attachment noch existiert
      attachment = ActiveStorage::Attachment.find_by(blob_id: blob.id)
      return unless attachment

      # WICHTIG: Erst prüfen ob Original-Blob funktioniert
      blob.open do |file|
        unless file.size > 0
          Rails.logger.error "Original blob #{blob.id} is empty or corrupted"
          return
        end
      end

      # Lade das Bild und verarbeite es
      image_data = blob.download
      image = Vips::Image.new_from_buffer(image_data, "")
      
      # Nur verkleinern, wenn das Bild zu breit ist
      if image.width > 1200
        Rails.logger.info "Resizing image from #{image.width}px to 1200px for blob #{blob.id}"
        
        image = image.resize(1200.0 / image.width)
        
        # Erstelle eine temporäre Datei für das verarbeitete Bild
        tempfile = Tempfile.new(["processed_#{blob.id}", ".jpg"])
        
        begin
          image.write_to_file(tempfile.path, Q: 85)
          
          # SICHERER: Erstelle neuen Blob erst wenn alles funktioniert
          processed_blob = ActiveStorage::Blob.create_and_upload!(
            io: File.open(tempfile.path),
            filename: blob.filename.to_s.gsub(/\.[^.]+$/, '.jpg'), # Force .jpg extension
            content_type: "image/jpeg"
          )
          
          # Verifiziere dass der neue Blob funktioniert
          processed_blob.open do |file|
            if file.size <= 0
              Rails.logger.error "Processed blob is empty for original blob #{blob.id}"
              processed_blob.purge
              return
            end
          end
          
          # Ersetze Blob nur wenn Upload erfolgreich war UND verifiziert
          if processed_blob.persisted?
            old_blob_id = attachment.blob.id
            attachment.update!(blob: processed_blob)
            
            Rails.logger.info "Successfully replaced blob #{old_blob_id} with #{processed_blob.id}"
            
            # Lösche alten Blob erst nach erfolgreichem Update
            blob.purge
          else
            Rails.logger.error "Failed to persist processed blob for original blob #{blob.id}"
          end
          
        ensure
          tempfile.close
          tempfile.unlink
        end
      else
        Rails.logger.info "Image #{blob.id} is already optimal size (#{image.width}px)"
      end
      
      # Erstelle Varianten für den finalen Blob (mit Retry-Logic)
      create_variants_with_retry(attachment.reload.blob)
      
      Rails.logger.info "Successfully processed image #{picture_id}"
      
    rescue Vips::Error => e
      Rails.logger.error "VIPS Error processing picture #{picture_id}: #{e.message}"
      # Bei VIPS-Fehlern das Original NICHT löschen
    rescue ActiveStorage::IntegrityError => e
      Rails.logger.error "Integrity Error for picture #{picture_id}: #{e.message}"
      # Bei Integritätsfehlern das Original NICHT löschen
    rescue => e
      Rails.logger.error "Error processing picture #{picture_id}: #{e.class} - #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      # Bei allen anderen Fehlern das Original NICHT löschen
    end
  end

  private

  def create_variants_with_retry(blob, max_retries = 3)
    retries = 0
    
    begin
      attachment = ActiveStorage::Attachment.find_by(blob: blob)
      return unless attachment
      
      # Erstelle verschiedene Varianten mit Fehlerbehandlung
      variants = [
        { name: 'thumbnail', options: { resize_to_limit: [400, 250] } },
        { name: 'gallery', options: { resize_to_fill: [600, 250] } },
        { name: 'logo', options: { resize_to_fill: [112, 112] } }
      ]
      
      variants.each do |variant_config|
        begin
          variant = attachment.variant(variant_config[:options])
          variant.processed
          Rails.logger.info "Created #{variant_config[:name]} variant for blob #{blob.id}"
        rescue => e
          Rails.logger.error "Failed to create #{variant_config[:name]} variant for blob #{blob.id}: #{e.message}"
        end
      end
      
    rescue => e
      retries += 1
      if retries < max_retries
        Rails.logger.warn "Retry #{retries}/#{max_retries} creating variants for blob #{blob.id}: #{e.message}"
        sleep(retries * 2) # Exponential backoff
        retry
      else
        Rails.logger.error "Failed to create variants for blob #{blob.id} after #{max_retries} retries: #{e.message}"
      end
    end
  end
end