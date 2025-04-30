require 'json'

# Read the JSON data
positions_data = JSON.parse(File.read('db/positions.json'))

positions_data.each do |position_data|
  # Create or find organization
  organization = Organization.find_or_create_by!(
    name: position_data['organization_name'],
    email: position_data['contact']['email'],
    contact_number: position_data['contact']['phone'],
    city: position_data['address']['city'],
    zip: position_data['address']['postal_code'],
    street: position_data['address']['street'],
    housenumber: position_data['address']['house_number'],
    contact_person: position_data['contact']['name'],
    description: position_data['organization_description']
  )

  # Create position
  position = organization.positions.create!(
    title: position_data['role'],
    description: position_data['tasks_description'],
    benefits: position_data['benefits'],
    duration: position_data['duration'],
    weekly_time_commitment: position_data['weekly_time_commitment'],
    creative_skills: position_data['ratings']['Creative Skills'],
    technical_skills: position_data['ratings']['Technical Skills'],
    social_skills: position_data['ratings']['Social Skills'],
    language_skills: position_data['ratings']['Language Skills'],
    flexibility: position_data['ratings']['Flexibility']
  )

  # Create FAQs
  position_data['faq'].each do |faq_data|
    position.frequently_asked_questions.create!(
      question: faq_data['question'],
      answer: faq_data['answer']
    )
  end

  # Attach images if they exist
  if position_data['materials']['photos']['photo1']
    position.mainPicture.attach(io: File.open("public/#{position_data['materials']['photos']['photo1']['url']}"), filename: File.basename(position_data['materials']['photos']['photo1']['url']))
  end

  if position_data['materials']['photos']['photo2']
    position.picture1.attach(io: File.open("public/#{position_data['materials']['photos']['photo2']['url']}"), filename: File.basename(position_data['materials']['photos']['photo2']['url']))
  end

  if position_data['materials']['photos']['photo3']
    position.picture2.attach(io: File.open("public/#{position_data['materials']['photos']['photo3']['url']}"), filename: File.basename(position_data['materials']['photos']['photo3']['url']))
  end

  puts "Created position: #{position.title} for organization: #{organization.name}"
end 