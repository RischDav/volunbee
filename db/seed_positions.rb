require 'json'

# Read the JSON data
positions_data = JSON.parse(File.read('db/positions.json'))

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
  end
end

positions_data.each do |position_data|
  sleep(2) # Increased delay between positions

  # Create or find organization
  organization = with_retry do
    Organization.find_or_create_by!(
      name: position_data['organization_name'],
      email: position_data['contact']['email'],
      contact_number: position_data['contact']['phone'],
      city: position_data['address']['city'],
      zip: position_data['address']['postal_code'],
      street: position_data['address']['street'],
      housenumber: position_data['address']['house_number'],
      contact_person: position_data['contact']['name'],
      description: position_data['organization_description'],
      organization_code: position_data['organization_code']
    )
  end
  next unless organization

  # Skip if organization already has 3 positions
  next if organization.positions.count >= 3

  # Create position with required fields
  position = organization.positions.new(
    title: position_data['role'].length >= 15 ? position_data['role'] : "#{position_data['role']} - #{position_data['project_or_local_group'] || position_data['organization_name']}",
    description: position_data['tasks_description'],
    benefits: position_data['benefits'],
    position_temporary: position_data['position_temporary'],
    weekly_time_commitment: position_data['weekly_time_commitment'].to_i,
    creative_skills: position_data['ratings']['Creative Skills'],
    technical_skills: position_data['ratings']['Technical Skills'],
    social_skills: position_data['ratings']['Social Skills'],
    language_skills: position_data['ratings']['Language Skills'],
    flexibility: position_data['ratings']['Flexibility'],
    position_code: position_data['position_code'],
    released: true,
    online: true,
    is_active: true
  )

  # Attach images if they exist
  if position_data['materials']['photos']['photo1']
    file_path = Rails.root.join('public', position_data['materials']['photos']['photo1']['url'])
    if File.exist?(file_path)
      position.mainPicture.attach(
        io: File.open(file_path),
        filename: File.basename(position_data['materials']['photos']['photo1']['url'])
      )
    end
  end

  if position_data['materials']['photos']['photo2']
    file_path = Rails.root.join('public', position_data['materials']['photos']['photo2']['url'])
    if File.exist?(file_path)
      position.picture1.attach(
        io: File.open(file_path),
        filename: File.basename(position_data['materials']['photos']['photo2']['url'])
      )
    end
  end

  if position_data['materials']['photos']['photo3']
    file_path = Rails.root.join('public', position_data['materials']['photos']['photo3']['url'])
    if File.exist?(file_path)
      position.picture2.attach(
        io: File.open(file_path),
        filename: File.basename(position_data['materials']['photos']['photo3']['url'])
      )
    end
  end

  # Save the position with retry
  success = with_retry do
    if position.save
      # Create FAQs
      position_data['faq'].each do |faq_data|
        position.frequently_asked_questions.create!(
          question: faq_data['question'],
          answer: faq_data['answer']
        )
      end

      puts "Created position: #{position.title} for organization: #{organization.name}"
      puts "Attached images: #{position.mainPicture.filename}, #{position.picture1&.filename}, #{position.picture2&.filename}"
      true
    else
      puts "Failed to create position: #{position.errors.full_messages}"
      false
    end
  end

  next unless success
end 