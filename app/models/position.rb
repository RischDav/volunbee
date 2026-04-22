class Position < ApplicationRecord
  # Use a business field named `type` without triggering STI
  self.inheritance_column = :_type_disabled
  belongs_to :organization, optional: true, counter_cache: true
  belongs_to :university, optional: true, counter_cache: true
  belongs_to :user, optional: true
  has_many :frequently_asked_questions, dependent: :destroy
  has_many :messages, dependent: :destroy
  has_many :user_events, dependent: :destroy
  accepts_nested_attributes_for :frequently_asked_questions, allow_destroy: true, reject_if: ->(attributes) { attributes['question'].blank? && attributes['answer'].blank? }
  enum :type, { volunteering: 1, freetime: 2, university_position: 3 }, suffix: true

  # Each position can have multiple images
  has_one_attached :main_picture
  has_one_attached :picture1
  has_one_attached :picture2
  has_one_attached :picture3

  # Validations
  validates :title, presence: true, length: { in: 15..75 }
  validates :benefits, length: { in: 100..1000 }
  validates :description, length: { in: 100..1000 }
  validate :organization_or_university_present
  validate :student_cannot_create_position, on: :create

  # signup_page muss vorhanden sein, wenn das Flag gesetzt ist
  validates :signup_page, presence: true, if: :has_own_signup_page?
  
  # Optional: Validierung, ob es eine echte URL ist
  validates :signup_page, format: { with: URI::DEFAULT_PARSER.make_regexp, message: "muss eine gültige URL sein" }, if: -> { signup_page.present? }

  # Main picture validations
  # validates :main_picture, presence: true
  validates :main_picture, presence: true
  validate :main_picture_format
  validate :main_picture_size

  validates :creative_skills, :technical_skills, :social_skills, :language_skills, :flexibility,
            numericality: { only_integer: true, greater_than_or_equal_to: 1, less_than_or_equal_to: 5 }

  validate :pictures_size
  validate :organization_position_limit

  after_commit :process_pictures, on: [:create, :update]
  after_update :send_modification_emails_if_needed

  # Categorical type of position (use 2-arg form to avoid Ruby keyword args ambiguity)
  enum :type, {
    volunteering: 1,
    freetime: 2,
    university_position: 3
  }

  # Validate against enum keys ("volunteering", "freetime", ...)
  validates :type, presence: true, inclusion: { in: types.keys }

  # Scopes for common queries
  scope :active, -> { where(is_active: true) }
  scope :released, -> { where(released: true) }
  scope :online, -> { where(online: true) }
  scope :published, -> { where(released: true, online: true) }
  scope :draft, -> { where(released: false, online: false) }
  scope :approved_but_offline, -> { where(released: true, online: false) }
  scope :for_university, ->(uni_id) {
    left_outer_joins(:organization).where(
      "positions.university_id = ? OR organizations.university_id = ?", 
      uni_id, uni_id
    )
  }
  
  # Scopes for filtering by relationship
  scope :for_organization, ->(org_id) { where(organization_id: org_id) }
  scope :for_university, ->(uni_id) { where(university_id: uni_id) }
  scope :by_type, ->(position_type) { where(type: position_type) }
  
  # Scope for student visibility
  scope :visible_to_student, ->(student) {
    where(
      "(visibility = ? OR ((visibility IS NULL OR visibility = ?) AND university_id = ?)) AND released = ? AND online = ?",
      'all', 'university', student.university_id, true, true
    )
  }

  # Instance method to check if position is published
  def published?
    released? && online?
  end
  
  # Scope with eager loading for performance
  scope :with_associations, -> { includes(:organization, :university, :user, :frequently_asked_questions) }
  scope :with_images, -> { with_attached_main_picture.with_attached_picture1.with_attached_picture2.with_attached_picture3 }

  # Direkte S3-URL Helper-Methoden
  def direct_image_url(variant_options = nil)
    return nil unless main_picture.attached?

    begin
      if variant_options
        main_picture.variant(variant_options).processed.url
      else
        main_picture.url
      end
    rescue ActiveStorage::FileNotFoundError, ActiveStorage::IntegrityError
      Rails.logger.error "Main picture not found in storage for position #{id}"
      nil
    rescue => e
      Rails.logger.error "Error generating main picture URL for position #{id}: #{e.message}"
      nil
    end
  end

  def direct_thumbnail_url
    direct_image_url(resize_to_limit: [400, 250])
  end

  def direct_gallery_url
    direct_image_url(resize_to_fill: [600, 250])
  end

  def direct_logo_url
    direct_image_url(resize_to_fill: [112, 112])
  end

  # Für alle Bilder direkte URLs
  def all_direct_urls
    {
      main_picture: direct_image_url,
      thumbnail: direct_thumbnail_url,
      gallery: direct_gallery_url,
      logo: direct_logo_url,
      picture1: safe_picture_url(:picture1),
      picture2: safe_picture_url(:picture2),
      picture3: safe_picture_url(:picture3)
    }.compact
  end

  def picture_urls
    pictures = [:main_picture, :picture1, :picture2, :picture3]
    pictures.each_with_object({}) do |picture, urls|
      if send(picture).attached?
        begin
          urls[picture] = send(picture).url
        rescue ActiveStorage::FileNotFoundError
          Rails.logger.error "Picture #{picture} not found in storage for position #{id}"
          urls[picture] = nil
        rescue => e
          Rails.logger.error "Error getting URL for #{picture} in position #{id}: #{e.message}"
          urls[picture] = nil
        end
      end
    end.compact
  end

  def image_url
    direct_image_url
  end

  def thumbnail_url
    direct_thumbnail_url
  end

  # Check if main picture is accessible
  def main_picture_accessible?
    return false unless main_picture.attached?

    begin
      main_picture.blob.open { |file| file.size > 0 }
      true
    rescue ActiveStorage::FileNotFoundError, ActiveStorage::IntegrityError
      false
    rescue => e
      Rails.logger.error "Error checking main picture accessibility for position #{id}: #{e.message}"
      false
    end
  end

  # Get safe fallback image
  def safe_main_picture_url
    url = direct_image_url
    return url if url && main_picture_accessible?

    # Fallback zu anderen Bildern wenn main_picture nicht verfügbar
    [:picture1, :picture2, :picture3].each do |pic|
      if send(pic).attached?
        begin
          return send(pic).url
        rescue ActiveStorage::FileNotFoundError
          next
        end
      end
    end

    nil # Kein Bild verfügbar
  end

  # Email notification methods (public)
  def should_send_modification_emails?
    # Send emails for published positions when there are meaningful changes
    # Always notify creator, and notify applicants only if there are any
    published? && has_meaningful_changes?
  end

  def send_modification_emails
    # Get the changes that occurred
    meaningful_changes = extract_meaningful_changes
    
    # Send email to applicants if there are any
    if has_applicants?
      applicant_users = messages.applications.includes(:user).map(&:user).compact.uniq
      
      applicant_users.each do |applicant|
        begin
          PositionMailer.position_modified(applicant, self, meaningful_changes).deliver_later
        rescue => e
          Rails.logger.error "Failed to send position modification email to user #{applicant.id}: #{e.message}"
        end
      end
    end

    # Always send confirmation email to the position creator (university staff)
    if user.present?
      begin
        PositionMailer.position_modified_creator(user, self, meaningful_changes).deliver_later
      rescue => e
        Rails.logger.error "Failed to send position modification confirmation email to creator #{user.id}: #{e.message}"
      end
    end
  end

  def send_modification_emails_if_needed
    if should_send_modification_emails?
      send_modification_emails
    end
  end

  def has_applicants?
    messages.applications.exists?
  end

  def has_meaningful_changes?
    # Define which fields are meaningful for applicants (using actual Position model fields)
    meaningful_fields = %w[title description benefits weekly_time_commitment appointment type]
    meaningful_fields.any? { |field| saved_changes.key?(field) }
  end

  def extract_meaningful_changes
    meaningful_fields = {
      'title' => 'Titel',
      'description' => 'Beschreibung', 
      'benefits' => 'Vorteile',
      'weekly_time_commitment' => 'Wöchentliche Arbeitszeit',
      'appointment' => 'Termin',
      'type' => 'Typ'
    }
    
    changes = {}
    meaningful_fields.each do |field, german_name|
      if saved_changes.key?(field)
        changes[german_name] = saved_changes[field]
      end
    end
    
    changes
  end

  private

  def organization_or_university_present
    if organization.nil? && university.nil?
      errors.add(:base, "❌ Die Position muss entweder einer Organisation oder einer Universität zugeordnet sein.")
    end
  end

  def student_cannot_create_position
    # Only block if user has university affiliation AND role 0 (normal user)
    if user&.affiliation&.university_id.present? && user&.affiliation&.role == UserAffiliation::NORMAL_USER
      errors.add(:base, '❌ Studenten können keine neuen Positionen erstellen. Nur Organisationen und Universitätsmitarbeiter haben diese Berechtigung.')
    end
  end

  # Validiert das Format des main_picture
  def main_picture_format
    return unless main_picture.attached?

    unless main_picture.blob.content_type.in?(['image/jpeg', 'image/jpg', 'image/png', 'image/webp'])
      errors.add(:main_picture, 'must be a JPEG, PNG, or WebP image')
    end
  end

  # Validiert die Größe des main_picture
  def main_picture_size
    return unless main_picture.attached?

    if main_picture.blob.byte_size > 10.megabytes
      errors.add(:main_picture, 'file size must be less than 10 MB')
    end

    if main_picture.blob.byte_size < 1.kilobyte
      errors.add(:main_picture, 'file size must be at least 1 KB')
    end
  end

  # Validiert dass das main_picture tatsächlich in S3 existiert
  def main_picture_exists_in_storage
    return unless main_picture.attached?

    begin
      # Versuche die Datei zu öffnen um sicherzustellen dass sie existiert
      main_picture.blob.open do |file|
        unless file.size > 0
          errors.add(:main_picture, 'file appears to be empty')
        end
      end
    rescue ActiveStorage::FileNotFoundError
      errors.add(:main_picture, 'file not found in storage')
    rescue ActiveStorage::IntegrityError
      errors.add(:main_picture, 'file integrity check failed')
    rescue => e
      Rails.logger.error "Error validating main picture for position #{id}: #{e.message}"
      errors.add(:main_picture, 'could not be validated')
    end
  end

  # Validiert die Größe aller angehängten Bilder
  def pictures_size
    [main_picture, picture1, picture2, picture3].each_with_index do |picture, index|
      next unless picture.attached?

      picture_name = index == 0 ? 'main_picture' : "picture#{index}"

      if picture.blob.byte_size > 10.megabytes
        errors.add(picture_name.to_sym, "file size must be less than 10 MB")
      end

      unless picture.blob.content_type.in?(['image/jpeg', 'image/jpg', 'image/png', 'image/webp'])
        errors.add(picture_name.to_sym, 'must be a JPEG, PNG, or WebP image')
      end
    end
  end

  # Validiert das Limit von Positionen pro Organisation
  def organization_position_limit
    return unless organization

    if new_record? && organization.positions.count >= 3
      errors.add(:base, "Maximum of 3 positions allowed per organization")
    end
  end

  # Startet die Bildverarbeitung im Hintergrund
  def process_pictures
    # Nur main_picture verarbeiten wenn es sich geändert hat
    if main_picture.attached? && saved_change_to_attribute?('main_picture')
      ProcessPictureJob.set(wait: 10.seconds).perform_later(main_picture.blob.id)
    end

    # Andere Bilder verarbeiten wenn sie sich geändert haben
    [picture1, picture2, picture3].each_with_index do |picture, index|
      attribute_name = "picture#{index + 1}"
      if picture.attached? && saved_change_to_attribute?(attribute_name)
        ProcessPictureJob.set(wait: 10.seconds).perform_later(picture.blob.id)
      end
    end
  end

  # Sichere URL-Generierung für zusätzliche Bilder
  def safe_picture_url(picture_name)
    picture = send(picture_name)
    return nil unless picture.attached?

    begin
      picture.url
    rescue ActiveStorage::FileNotFoundError
      Rails.logger.error "Picture #{picture_name} not found in storage for position #{id}"
      nil
    rescue => e
      Rails.logger.error "Error getting URL for #{picture_name} in position #{id}: #{e.message}"
      nil
    end
  end
end