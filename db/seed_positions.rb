require 'json'

puts "Starting seed_positions.rb..."

# Load your JSON data from file
positions_data = JSON.parse(File.read(Rails.root.join('db', 'positions.json')))
puts "Loaded #{positions_data.size} positions from JSON."

photo_keys = %w[photo1 photo2 photo3 photo4]
attachment_names = %i[main_picture picture1 picture2 picture3]

def with_retry(max_retries = 3, delay = 2)
  retries = 0
  begin
    yield
  rescue ActiveRecord::StatementTimeout => e
    retries += 1
    if retries <= max_retries
      puts "Database lock detected, retrying in #{delay} seconds (attempt #{retries}/#{max_retries})..."
      sleep(delay)
      retry
    else
      puts "Max retries reached. Moving to next position..."
      return nil
    end
  rescue => e
    puts "Exception in with_retry: #{e.class} - #{e.message}"
    return nil
  end
end

# Optional: clear all positions before seeding
# Position.destroy_all

positions_data.each_with_index do |position_data, idx|
  puts "Processing position ##{idx + 1}..."

  sleep(2) # Optional: reduce DB stress

  organization = with_retry do
    Organization.find_or_create_by!(
      name: position_data['organization_name'],
      email: position_data.dig('contact', 'email'),
      contact_number: position_data.dig('contact', 'phone'),
      city: position_data.dig('address', 'city'),
      zip: position_data.dig('address', 'postal_code'),
      street: position_data.dig('address', 'street'),
      housenumber: position_data.dig('address', 'house_number'),
      contact_person: position_data.dig('contact', 'name'),
      description: position_data['organization_description'],
      organization_code: position_data['organization_code']
    )
  end
  if organization.nil?
    puts "Organization creation failed for position ##{idx + 1}."
    next
  else
    puts "Organization found/created: #{organization.name} (ID: #{organization.id})"
  end

  # Compose title with fallback if too short
  title = if position_data['role'].length >= 15
            position_data['role']
          else
            "#{position_data['role']} - #{position_data['project_or_local_group'] || position_data['organization_name']}"
          end

  position = organization.positions.new(
    title: title,
    description: position_data['tasks_description'],
    benefits: position_data['benefits'],
    position_temporary: position_data['position_temporary'],
    weekly_time_commitment: position_data['weekly_time_commitment'].to_i,
    creative_skills: position_data.dig('ratings', 'Creative Skills'),
    technical_skills: position_data.dig('ratings', 'Technical Skills'),
    social_skills: position_data.dig('ratings', 'Social Skills'),
    language_skills: position_data.dig('ratings', 'Language Skills'),
    flexibility: position_data.dig('ratings', 'Flexibility'),
    position_code: position_data['position_code'],
    released: true,
    online: true,
    is_active: true
  )

  # Attach photos if files exist
  photo_keys.each_with_index do |photo_key, idx2|
    photo_info = position_data.dig('materials', 'photos', photo_key)
    next unless photo_info && photo_info['url']

    file_path = Rails.root.join('public', photo_info['url'])
    puts "Checking file path: #{file_path}"

    if File.exist?(file_path)
      puts "File exists, attaching #{photo_info['url']} to #{attachment_names[idx2]}..."
      begin
        position.send(attachment_names[idx2]).attach(
          io: File.open(file_path, 'rb'),
          filename: File.basename(file_path)
        )
        puts "Attached #{photo_info['url']} to #{attachment_names[idx2]}"
      rescue => e
        puts "Failed to attach #{photo_info['url']}: #{e.message}"
      end
    else
      puts "File does NOT exist at: #{file_path}"
    end
  end

  success = with_retry do
    if position.save
      Array(position_data['faq']).each do |faq_data|
        position.frequently_asked_questions.create!(
          question: faq_data['question'],
          answer: faq_data['answer']
        )
      end
      puts "Created position: #{position.title} for organization: #{organization.name}"
      puts "Attachments: " + attachment_names.map { |name| position.send(name).attached? ? position.send(name).filename.to_s : 'none' }.join(', ')
      true
    else
      puts "Failed to create position: #{position.errors.full_messages.join(', ')}"
      false
    end
  end

  unless success
    puts "Failed to save position ##{idx + 1}."
    next
  end
end

puts "Finished seed_positions.rb."
