# Test Script für die neue User-Affiliation Struktur
puts "=== Testing New User Affiliation Structure ==="

# Test 1: Student Registrierung
puts "\n1. Testing Student Registration..."
student_email = "test.student@tum.de"

# Prüfe ob Uni existiert
uni = University.find_by(name: 'Technische Universität München')
puts "University found: #{uni.present?}"

if uni
  # Erstelle Test User
  user = User.new(
    email: student_email,
    password: "TestPass123!",
    password_confirmation: "TestPass123!"
  )
  
  if user.save
    puts "✅ User created: #{user.email}"
    
    # Erstelle University Affiliation
    affiliation = UserAffiliation.new(
      user: user,
      university: uni,
      role: :user
    )
    
    if affiliation.save
      puts "✅ Student affiliation created"
      puts "   - User is student: #{user.student?}"
      puts "   - User university: #{user.university&.name}"
      puts "   - User is admin: #{user.admin?}"
    else
      puts "❌ Affiliation errors: #{affiliation.errors.full_messages}"
    end
  else
    puts "❌ User errors: #{user.errors.full_messages}"
  end
end

# Test 2: Organization Registrierung
puts "\n2. Testing Organization Registration..."
org_email = "test.org@example.com"

# Erstelle Test Organization
org = Organization.new(
  name: "Test Organization",
  organization_code: "test_org"
)

if org.save
  puts "✅ Organization created: #{org.name}"
  
  # Erstelle Test User
  user = User.new(
    email: org_email,
    password: "TestPass123!",
    password_confirmation: "TestPass123!"
  )
  
  if user.save
    puts "✅ User created: #{user.email}"
    
    # Erstelle Organization Affiliation
    affiliation = UserAffiliation.new(
      user: user,
      organization: org,
      role: :user
    )
    
    if affiliation.save
      puts "✅ Organization affiliation created"
      puts "   - User is organization?: #{user.organization?}"
      puts "   - User organization: #{user.organization&.name}"
      puts "   - User is admin: #{user.admin?}"
    else
      puts "❌ Affiliation errors: #{affiliation.errors.full_messages}"
    end
  else
    puts "❌ User errors: #{user.errors.full_messages}"
  end
else
  puts "❌ Organization errors: #{org.errors.full_messages}"
end

# Test 3: Platform Admin
puts "\n3. Testing Platform Admin..."
admin_email = "admin@platform.com"

user = User.new(
  email: admin_email,
  password: "TestPass123!",
  password_confirmation: "TestPass123!"
)

if user.save
  puts "✅ Admin user created: #{user.email}"
  
  # Erstelle Admin Affiliation (ohne org/uni)
  affiliation = UserAffiliation.new(
    user: user,
    role: :admin
  )
  
  if affiliation.save
    puts "✅ Admin affiliation created"
    puts "   - User is admin: #{user.admin?}"
    puts "   - User is platform admin: #{user.platform_admin?}"
    puts "   - User organization: #{user.organization&.name || 'None'}"
    puts "   - User university: #{user.university&.name || 'None'}"
  else
    puts "❌ Affiliation errors: #{affiliation.errors.full_messages}"
  end
else
  puts "❌ User errors: #{user.errors.full_messages}"
end

puts "\n=== Test Complete ==="
