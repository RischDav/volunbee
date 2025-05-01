require "test_helper"

class PositionsControllerTest < ActionDispatch::IntegrationTest
  test "should create position with FAQs" do
    organization = organizations(:one) # Assuming you have an organization fixture
    sign_in organization.users.first # Assuming you have authentication set up

    assert_difference('Position.count') do
      assert_difference('FrequentlyAskedQuestion.count', 2) do
        post positions_url, params: {
          position: {
            title: "Test Position",
            description: "Test Description",
            benefits: "Test Benefits",
            creative_skills: 3,
            technical_skills: 3,
            social_skills: 3,
            language_skills: 3,
            flexibility: 3,
            frequently_asked_questions_attributes: [
              {
                question: "Question 1?",
                answer: "Answer 1"
              },
              {
                question: "Question 2?",
                answer: "Answer 2"
              }
            ]
          }
        }
      end
    end

    assert_redirected_to position_url(Position.last)
    assert_equal 2, Position.last.frequently_asked_questions.count
  end

  test "should update position with FAQs" do
    position = positions(:one) # Assuming you have a position fixture
    sign_in position.organization.users.first

    assert_no_difference('Position.count') do
      assert_difference('FrequentlyAskedQuestion.count', 1) do
        patch position_url(position), params: {
          position: {
            frequently_asked_questions_attributes: [
              {
                question: "New Question?",
                answer: "New Answer"
              }
            ]
          }
        }
      end
    end

    assert_redirected_to position_url(position)
    assert_equal 1, position.frequently_asked_questions.count
  end
end 