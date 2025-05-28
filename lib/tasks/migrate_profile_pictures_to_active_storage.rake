require 'open-uri'

namespace :organizations do
  desc "Migrate profile_picture column to ActiveStorage"
  task migrate_profile_pictures: :environment do
    Organization.find_each do |org|
      next if org.profile_picture.blank?
      next if org.profile_picture_attachment.present? # Already migrated

      begin
        file = URI.open(org.profile_picture)
        org.profile_picture.attach(io: file, filename: File.basename(URI.parse(org.profile_picture).path))
        puts "Migrated: #{org.name}"
      rescue => e
        puts "Failed for #{org.name}: #{e.message}"
      end
    end
  end
end