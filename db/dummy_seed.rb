org = Organization.find_or_create_by!(
  name: 'Dummy Organization',
  email: 'org@example.com',
  contact_number: '123456789',
  city: 'Berlin',
  zip: '10115',
  street: 'Teststraße',
  housenumber: '1',
  website: 'https://dummy.org',
  description: 'Test organization',
  instagram_url: '',
  linkedin_url: '',
  facebook_link: '',
  released: true,
  organization_code: 'DUMMY123',
  contact_person: 'John Doe',
  tiktok_url: '',
  linktree_url: ''
)
uni = University.find_or_create_by!(name: 'Dummy University', email: 'uni@example.com')

user_org = User.find_or_create_by!(email: 'user_org@example.com')
user_org.update!(
  password: 'Test_password0',
  password_confirmation: 'Test_password0',
  confirmed_at: Time.now
)
UserAffiliation.where(user: user_org).destroy_all
UserAffiliation.find_or_create_by!(user: user_org, organization: org, role: 1)

user_uni = User.find_or_create_by!(email: 'user_uni@tum.de')
user_uni.update!(
  password: 'Test_password0',
  password_confirmation: 'Test_password0',
  confirmed_at: Time.now
)
UserAffiliation.where(user: user_uni).destroy_all
UserAffiliation.create!(user: user_uni, university: uni, role: UserAffiliation::ADMIN)

puts 'Dummy organization, university, and test users created.'
