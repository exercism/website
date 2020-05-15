require "test_helper"

class Mentor::StartConversationTest < ActiveSupport::TestCase
  test "creates conversation" do
    mentor = create :user
    request = create :solution_mentor_request

    Mentor::StartConversation.(mentor, request)

    assert_equal 1, Solution::MentorConversation.count

    conversation = Solution::MentorConversation.last
    assert_equal mentor, conversation.mentor
    assert_equal request, conversation.request
    assert_equal request.solution, conversation.solution
  end

  test "fulfils request" do
    request = create :solution_mentor_request

    assert_equal :pending, request.status
    Mentor::StartConversation.(create(:user), request)
    assert_equal :fulfilled, request.reload.status
  end

  test "conversation not created if request fails" do
    request = create :solution_mentor_request
    request.expects(:fulfilled!).raises

    assert_equal :pending, request.status
    assert_equal 0, Solution::MentorConversation.count

    begin
      Mentor::StartConversation.(create(:user), request)
    rescue
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorConversation.count
  end

  test "request not fullfiled if conversation fails" do
    request = create :solution_mentor_request
    Solution::MentorConversation.expects(:create!).raises

    # Sanity checks
    assert_equal :pending, request.status
    assert_equal 0, Solution::MentorConversation.count

    begin
      Mentor::StartConversation.(create(:user), request)
    rescue
    end

    assert_equal :pending, request.reload.status
    assert_equal 0, Solution::MentorConversation.count
  end
end
