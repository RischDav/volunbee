# Comprehensive test data for all 4 roles
# run this: rails runner db/test_data_comprehensive.rb

puts "=== COMPREHENSIVE TEST DATA ==="

puts "\n1. Checking universities..."
universities = University.all
universities.each do |university|
  puts "University: #{university.name} (ID: #{university.id})"
end

puts "\n2. Creating test position for Hochschule Heilbronn..."

# Find Hochschule Heilbronn university
hsh = University.find_by(name: 'Hochschule Heilbronn')
if hsh
  puts "Found Hochschule Heilbronn university (ID: #{hsh.id})"
  
  # Create a test position for HSH with proper validation lengths
  position = Position.new(
    title: "Research Assistant Position at Hochschule Heilbronn Campus",
    description: "We are seeking motivated students to assist with research projects at Hochschule Heilbronn. This position involves data collection, analysis, and supporting faculty research initiatives. Ideal for students interested in gaining research experience and working closely with professors on cutting-edge projects. The role includes literature reviews, data entry, statistical analysis, and preparation of research materials.",
    benefits: "Hands-on research experience, mentorship from faculty, potential for publication, flexible schedule, networking opportunities, and academic credit possibilities. You will gain valuable skills in research methodology, data analysis, and academic writing. This position can also lead to thesis collaboration and potential employment opportunities after graduation.",
    creative_skills: 3,
    technical_skills: 4,
    social_skills: 2,
    language_skills: 3,
    flexibility: 3,
    is_active: true,
    released: true,
    online: true,
    position_temporary: false,
    weekly_time_commitment: 8,
    position_code: "hsh_research_assistant",
    university_id: hsh.id
  )
  
  # Skip validations for testing
  position.save(validate: false)
  
  puts "Created position: #{position.title} for university: #{hsh.name}"
  puts "Position ID: #{position.id}"
  puts "University ID: #{position.university_id}"
else
  puts "Hochschule Heilbronn university not found!"
end

puts "\n3. Testing student email assignments..."

# Test TUM student
tum_email = "amine.jradi@tum.de"
if tum_email.end_with?('@tum.de') || tum_email.end_with?('@mytum.de')
  tum_university = University.find_by(name: 'Technische Universität München')
  puts "Student with email #{tum_email} would be assigned to: #{tum_university&.name}"
else
  puts "Email domain not recognized for TUM"
end

# Test HSH student
hsh_email = "test.student@hs-heilbronn.de"
if hsh_email.end_with?('@hs-heilbronn.de')
  hsh_university = University.find_by(name: 'Hochschule Heilbronn')
  puts "Student with email #{hsh_email} would be assigned to: #{hsh_university&.name}"
else
  puts "Email domain not recognized for HSH"
end

puts "\n4. Testing role assignments..."

# Test organization role
puts "Organization role (0): #{User.roles.key(0)}"
puts "Admin role (1): #{User.roles.key(1)}"
puts "University role (2): #{User.roles.key(2)}"
puts "Student role (3): #{User.roles.key(3)}"

puts "\n5. Testing user creation for each role..."

# Test creating users for each role
begin
  # Organization user
  org_user = User.new(
    email: "org@example.com",
    password: "password123",
    role: :organization,
    organization_id: 1, # Assuming organization with ID 1 exists
    confirmed_at: Time.now
  )
  org_user.save(validate: false)
  puts "Created organization user: #{org_user.email} with role: #{org_user.role}"
rescue => e
  puts "Error creating organization user: #{e.message}"
end

begin
  # Admin user
  admin_user = User.new(
    email: "admin@example.com",
    password: "password123",
    role: :admin,
    confirmed_at: Time.now
  )
  admin_user.save(validate: false)
  puts "Created admin user: #{admin_user.email} with role: #{admin_user.role}"
rescue => e
  puts "Error creating admin user: #{e.message}"
end

begin
  # University user (TUM)
  tum_user = User.new(
    email: "tum@tum.de",
    password: "password123",
    role: :university,
    university_id: 0, # TUM
    confirmed_at: Time.now
  )
  tum_user.save(validate: false)
  puts "Created university user (TUM): #{tum_user.email} with role: #{tum_user.role}"
rescue => e
  puts "Error creating university user: #{e.message}"
end

begin
  # University user (HSH)
  hsh_user = User.new(
    email: "hsh@hs-heilbronn.de",
    password: "password123",
    role: :university,
    university_id: 1, # HSH
    confirmed_at: Time.now
  )
  hsh_user.save(validate: false)
  puts "Created university user (HSH): #{hsh_user.email} with role: #{hsh_user.role}"
rescue => e
  puts "Error creating university user: #{e.message}"
end

begin
  # Student user (TUM)
  tum_student = User.new(
    email: "student.tum@tum.de",
    password: "password123",
    role: :student,
    university_id: 0, # TUM
    confirmed_at: Time.now
  )
  tum_student.save(validate: false)
  puts "Created student user (TUM): #{tum_student.email} with role: #{tum_student.role}"
rescue => e
  puts "Error creating student user: #{e.message}"
end

begin
  # Student user (HSH)
  hsh_student = User.new(
    email: "student.hsh@hs-heilbronn.de",
    password: "password123",
    role: :student,
    university_id: 1, # HSH
    confirmed_at: Time.now
  )
  hsh_student.save(validate: false)
  puts "Created student user (HSH): #{hsh_student.email} with role: #{hsh_student.role}"
rescue => e
  puts "Error creating student user: #{e.message}"
end

puts "\n6. Testing position access..."

# Test which positions each user type can see
puts "\nPosition access by user type:"
puts "- Organizations: Can see positions where organization_id = their organization_id"
puts "- Universities: Can see positions where university_id = their university_id"
puts "- Students: Can see positions where university_id = their university_id"
puts "- Admins: Can see all positions"

puts "\n7. Summary of test data created:"
puts "- Universities: #{University.count} (TUM and HSH)"
puts "- Test positions: #{Position.where(position_code: ['tum_student_assistant', 'hsh_research_assistant']).count}"
puts "- Test users: #{User.where(email: ['org@example.com', 'admin@example.com', 'tum@tum.de', 'hsh@hs-heilbronn.de', 'student.tum@tum.de', 'student.hsh@hs-heilbronn.de']).count}"

puts "\n=== COMPREHENSIVE TEST COMPLETED ===" 