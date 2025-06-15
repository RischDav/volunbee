class ShowPositionsController < ApplicationController
  def index
    @positions = Position.includes(:organization, 
                                  main_picture_attachment: :blob)
                        .where(online: true, released: true)
  end

  def show
    @position = Position.includes(:organization, :frequently_asked_questions,
                                 main_picture_attachment: :blob,
                                 picture1_attachment: :blob,
                                 picture2_attachment: :blob,
                                 picture3_attachment: :blob)
                       .find(params[:id])
  end

  # Bereinigungsmethoden für fehlerhafte Varianten
  def self.purge_invalid_variants
    variant_records = ActiveStorage::VariantRecord.all
    
    puts "Überprüfe #{variant_records.count} Varianten..."
    
    variant_records.each do |variant|
      begin
        blob = ActiveStorage::Blob.find_by(id: variant.blob_id)
        next unless blob
        
        attachment = ActiveStorage::Attachment.find_by(record_type: "ActiveStorage::VariantRecord", 
                                                      record_id: variant.id, 
                                                      name: "image")
        
        if !attachment || !attachment.blob
          puts "Lösche ungültige Variante ohne Anhang für Blob #{variant.blob_id}"
          variant.destroy
          next
        end
        
        begin
          attachment.blob.open
        rescue ActiveStorage::FileNotFoundError
          puts "Lösche Variante mit fehlender Datei für Blob #{variant.blob_id}"
          attachment.purge
          variant.destroy
        end
      rescue => e
        puts "Fehler bei Variante #{variant.id}: #{e.message}"
      end
    end
    
    puts "Bereinigung abgeschlossen."
  end

  def self.purge_missing_files
    Position.find_each do |position|
      if position.main_picture.attached?
        begin
          position.main_picture.blob.open
        rescue ActiveStorage::FileNotFoundError
          puts "Purging missing file for #{position.title}"
          position.main_picture.purge
        end
      end
      
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

  def self.regenerate_all_variants
    processed_count = 0
    failed_count = 0
    
    Position.find_each do |position|
      [:main_picture, :picture1, :picture2, :picture3].each do |pic_attr|
        next unless position.send(pic_attr).attached?
        
        begin
          # Erstelle verschiedene Varianten
          position.send(pic_attr).variant(resize_to_fill: [112, 112]).processed
          position.send(pic_attr).variant(resize_to_fill: [600, 250]).processed
          position.send(pic_attr).variant(resize_to_limit: [400, 250]).processed
          
          processed_count += 1
          puts "Erfolgreich Varianten für Position ID #{position.id} (#{pic_attr}) erstellt"
        rescue => e
          failed_count += 1
          puts "Fehler bei Position #{position.id}, #{pic_attr}: #{e.message}"
        end
      end
    end
    
    puts "Abgeschlossen. Erfolgreich: #{processed_count}, Fehlgeschlagen: #{failed_count}"
  end

  private

  def safe_main_picture_url
    if main_picture.attached?
      begin
        main_picture.url
      rescue ActiveStorage::FileNotFoundError
        nil
      end
    end
  end
end