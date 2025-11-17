#!/usr/bin/env ruby
# Test script to verify email notifications

# Change to the Rails app directory
Dir.chdir('/Users/amine/LetsGoVolunteer-Backend')

# Load the Rails environment
require_relative 'config/environment'

puts "🔧 Testing Email Notification System"
puts "=" * 50

# Check environment variables
puts "📧 SMTP Configuration:"
puts "  Username: #{ENV['SMTP_USERNAME']}"
puts "  Password: #{ENV['SMTP_PASSWORD'] ? '[SET]' : '[NOT SET]'}"
puts ""

# Find a test position
position = Position.find(9)
puts "📍 Test Position:"
puts "  ID: #{position.id}"
puts "  Title: #{position.title}"
puts "  Published?: #{position.published?}"
puts "  Has User?: #{position.user.present?}"
puts "  User Email: #{position.user&.email}"
puts ""

# Test meaningful change detection
puts "🔍 Testing Change Detection:"
old_description = position.description
position.description = "This is a comprehensive test description that meets the minimum 100 character requirement for position descriptions. We are updating this position to test the email notification system and ensure that both applicants and position creators receive appropriate emails when meaningful changes are made to published positions."

puts "  Description changed: #{position.changed.include?('description')}"
puts ""

puts "💌 Attempting to send test email..."
begin
  # Save the position to trigger the callback
  position.save!
  puts "  ✅ Position updated successfully!"
  puts "  📤 Email notification should be sent to: #{position.user.email}"
  puts ""
  puts "🎯 Check your email inbox at: #{position.user.email}"
rescue => e
  puts "  ❌ Error: #{e.message}"
  puts "  📚 Backtrace: #{e.backtrace.first(3).join("\n  ")}"
end

puts ""
puts "🔄 To restart the Rails server and pick up changes:"
puts "  1. Stop the current server (Ctrl+C)"
puts "  2. Run: rails server"
puts "  3. Try editing the position again through the web interface"