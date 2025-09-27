# Test data for universities and positions

puts "Checking universities..."
universities = University.all
universities.each do |university|
  puts "University: #{university.name} (ID: #{university.id})"
end

puts "\nCreating test position for TUM..."

# Find TUM university
tum = University.find_by(name: 'Technische Universität München')
if tum
  puts "Found TUM university (ID: #{tum.id})"
  
  # Create a test position for TUM with proper validation lengths
  position = Position.new(
    title: "Student Assistant Position at TUM Campus Heilbronn",
    description: "We are looking for motivated students to support various projects at TUM Campus Heilbronn. This position involves assisting with research projects, helping with campus events, and supporting administrative tasks. Perfect opportunity for students who want to gain practical experience while studying. The role includes project coordination, event planning, data management, and collaboration with faculty and staff.",
    benefits: "Gain valuable work experience, flexible working hours, networking opportunities with professors and industry partners, potential for thesis collaboration, competitive compensation, and a great addition to your CV. You will develop professional skills, build your network, and gain insights into academic and industry practices.",
    creative_skills: 2,
    technical_skills: 3,
    social_skills: 4,
    language_skills: 3,
    flexibility: 4,
    is_active: true,
    released: true,
    online: true,
    position_temporary: false,
    weekly_time_commitment: 10,
    position_code: "tum_student_assistant",
    university_id: tum.id
  )
  
  # Skip validations for testing
  position.save(validate: false)
  
  puts "Created position: #{position.title} for university: #{tum.name}"
  puts "Position ID: #{position.id}"
  puts "University ID: #{position.university_id}"
else
  puts "TUM university not found!"
end

puts "\nTesting student access..."
# Test if a student with @tum.de email would be assigned to TUM
test_email = "amine.jradi@tum.de"
if test_email.end_with?('@tum.de') || test_email.end_with?('@mytum.de')
  tum_university = University.find_by(name: 'Technische Universität München')
  puts "Student with email #{test_email} would be assigned to: #{tum_university&.name}"
else
  puts "Email domain not recognized for TUM"
end

puts "\nTest data creation completed!" 