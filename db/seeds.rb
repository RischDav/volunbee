# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


require_relative 'seed_positions'

# Create universities
puts "Creating universities..."

tum = University.create!(
  id: 0,
  name: "Technische Universität München",
  email: "info@tum.de",
  contact_number: "+49 89 289 01",
  city: "München",
  zip: "80333",
  street: "Arcisstraße 21",
  website: "https://www.tum.de",
  description: "Technische Universität München is one of Europe's leading universities.",
  is_approved: true,
  released: true
)

hsh = University.create!(
  id: 1,
  name: "Hochschule Heilbronn",
  email: "info@hs-heilbronn.de",
  contact_number: "+49 7131 504 0",
  city: "Heilbronn",
  zip: "74081",
  street: "Max-Planck-Straße 39",
  website: "https://www.hs-heilbronn.de",
  description: "Hochschule Heilbronn is a university of applied sciences.",
  is_approved: true,
  released: true
)

puts "Universities created successfully!"

# Update existing users to have correct roles
puts "Updating existing users..."

# Update users with role 0 (previously 'user') to 'organization'
User.where(role: 0).update_all(role: 0) # organization role

# Update users with role 1 (previously 'admin') to 'admin'
User.where(role: 1).update_all(role: 1) # admin role

puts "Users updated successfully!"

puts "Seed data completed!"