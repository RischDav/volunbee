user = User.find_by(email: 'user_org@example.com')
org = Organization.find_by(email: 'org@example.com')

# main_picture_path = Dir.glob(Rails.root.join('public', 'images', '*')).first
# main_picture_file = main_picture_path ? File.open(main_picture_path) : nil

position = Position.new(
  title: 'Test Position for Organization',
  description: 'This is a test position description that is long enough to pass validation. ' * 3,
  benefits: 'These are the benefits of the test position. ' * 3,
  weekly_time_commitment: 5,
  position_temporary: false,
  creative_skills: 3,
  technical_skills: 3,
  social_skills: 3,
  language_skills: 3,
  flexibility: 3,
  organization_id: org.id,
  user: user
)
# if main_picture_file
#   position.main_picture.attach(io: main_picture_file, filename: File.basename(main_picture_path))
# end
if position.save
  puts 'Organization position created successfully.'
else
  puts 'Organization position creation failed:'
  puts position.errors.full_messages
end

user = User.find_by(email: 'user_uni@tum.de')
uni = University.find_by(email: 'uni@example.com')

position = Position.new(
  title: 'Test Position for University',
  description: 'This is a test position description that is long enough to pass validation. ' * 3,
  benefits: 'These are the benefits of the test position. ' * 3,
  weekly_time_commitment: 5,
  position_temporary: true,
  creative_skills: 4,
  technical_skills: 2,
  social_skills: 5,
  language_skills: 4,
  flexibility: 2,
  university_id: uni.id,
  user: user
)
# if main_picture_file
#   position.main_picture.attach(io: main_picture_file, filename: File.basename(main_picture_path))
# end
if position.save
  puts 'University position created successfully.'
else
  puts 'University position creation failed:'
  puts position.errors.full_messages
end

user = User.find_by(email: 'user_uni@tum.de') # Use the admin student email
uni = University.find_by(email: 'uni@example.com')

position = Position.new(
  title: 'Test Position for University (Admin)',
  description: 'This is a test position description that is long enough to pass validation. ' * 3,
  benefits: 'These are the benefits of the test position. ' * 3,
  weekly_time_commitment: 5,
  position_temporary: true,
  creative_skills: 4,
  technical_skills: 2,
  social_skills: 5,
  language_skills: 4,
  flexibility: 2,
  university_id: uni.id,
  user: user
)
if position.save
  puts 'University position (admin) created successfully.'
else
  puts 'University position (admin) creation failed:'
  puts position.errors.full_messages
end
