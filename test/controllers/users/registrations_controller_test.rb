require 'test_helper'

class Users::RegistrationsControllerTest < ActionDispatch::IntegrationTest
  test "student signup sends confirmation email" do
    assert_difference 'User.count', 1 do
      post user_registration_path, params: {
        user: {
          email: "student@tum.de",
          password: "StrongPass1!",
          password_confirmation: "StrongPass1!",
          role: "student"
        }
      }
    end
    user = User.last
    assert_not_nil user
    assert_equal "student@tum.de", user.email
    assert_enqueued_email_with Devise::Mailer, :confirmation_instructions
  end

  test "organization signup sends admin email" do
    assert_difference 'User.count', 1 do
      assert_difference 'Organization.count', 1 do
        post user_registration_path, params: {
          user: {
            email: "org@example.com",
            password: "StrongPass1!",
            password_confirmation: "StrongPass1!",
            role: "organization",
            organization_name: "TestOrg"
          }
        }
      end
    end
    assert_enqueued_email_with AdminMailer, :new_registration_email
  end
end