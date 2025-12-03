class ShowPositionsController < ApplicationController
  skip_before_action :authenticate_user!
  
  def index
    if user_signed_in?
      if current_user.organization?
        # Organization users: only their own org positions
        @positions = Position.published.for_organization(current_user.organization_id)
      elsif current_user.student?
        # Students: org positions + university positions (visibility logic)
        @positions = Position.published
      else
        # Other users (admins, university staff, etc): show all
        @positions = Position.published
      end
    else
      # Not logged in: show only organization positions
      @positions = Position.published.where.not(organization_id: nil)
    end
    @custom_navbar = true
  end

  def show
    @position = Position.with_associations.find(params[:id])
    @custom_navbar = true
    if user_signed_in? && current_user.student?
      UserEvent.create!(
        user_type: :student,
        action_type: :view_position,
        position: @position,
        university: current_user.university,
      )
    end
    render 'positions/show'
  end

  # Bereinigungsmethoden für fehlerhafte Varianten
  def self.purge_invalid_variants
    variant_records = ActiveStorage::VariantRecord.includes(:blob).all
    
    puts "Überprüfe #{variant_records.count} Varianten..."
    
    variant_records.each do |variant|
      begin
        variant.blob.open { |file| file.size }
      rescue ActiveStorage::FileNotFoundError, ActiveStorage::IntegrityError
        puts "Lösche korrupte Variante: #{variant.id}"
        variant.destroy
      rescue => e
        puts "Fehler bei Variante #{variant.id}: #{e.message}"
        variant.destroy
      end
    end
    
    puts "Bereinigung abgeschlossen."
  end

  def self.purge_missing_files
    Position.find_each do |position|
      [position.main_picture, position.picture1, position.picture2, position.picture3].each_with_index do |picture, index|
        next unless picture.attached?
        
        begin
          picture.blob.open { |file| file.size }
        rescue ActiveStorage::FileNotFoundError, ActiveStorage::IntegrityError
          pic_name = index == 0 ? 'main_picture' : "picture#{index}"
          puts "Lösche korruptes Bild #{pic_name} für Position #{position.id}"
          picture.purge
        end
      end
      
      # Position offline nehmen wenn main_picture fehlt
      if !position.main_picture.attached? && position.online?
        position.update(online: false)
        puts "Position #{position.id} offline genommen - kein main_picture"
      end
    end
  end

  def self.regenerate_all_variants
    processed_count = 0
    failed_count = 0
    
    Position.find_each do |position|
      [position.main_picture, position.picture1, position.picture2, position.picture3].each do |picture|
        next unless picture.attached?
        
        begin
          # Prüfe ob Bild verfügbar ist
          picture.blob.open { |file| file.size }
          
          # Erstelle Varianten
          picture.variant(resize_to_limit: [400, 250]).processed
          picture.variant(resize_to_fill: [600, 250]).processed
          picture.variant(resize_to_fill: [112, 112]).processed
          
          processed_count += 1
          puts "Varianten erstellt für Position #{position.id}"
          
        rescue => e
          failed_count += 1
          puts "Fehler bei Position #{position.id}: #{e.message}"
        end
      end
    end
    
    puts "Abgeschlossen. Erfolgreich: #{processed_count}, Fehlgeschlagen: #{failed_count}"
  end

  private

end