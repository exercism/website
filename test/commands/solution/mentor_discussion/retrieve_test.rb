require 'test_helper'

class Solution::MentorDiscussion::RetrieveTest < ActiveSupport::TestCase
  test "only retrieves user's solutions" do
    user = create :user

    valid = create :solution_mentor_discussion, :requires_mentor_action, mentor: user
    create :solution_mentor_discussion, :requires_mentor_action

    assert_equal [valid], Solution::MentorDiscussion::Retrieve.(user, page: 1)
  end

  test "only retrieves solutions requiring action" do
    user = create :user

    valid = create :solution_mentor_discussion, :requires_mentor_action, mentor: user
    create :solution_mentor_discussion, mentor: user

    assert_equal [valid], Solution::MentorDiscussion::Retrieve.(user, page: 1)
  end

  test "only retrieves relevant tracks" do
    user = create :user
    ruby = create :track, slug: :ruby
    js = create :track, slug: :js
    create :track, slug: :elixir

    create :solution_mentor_discussion, :requires_mentor_action, track: ruby, mentor: user
    create :solution_mentor_discussion, :requires_mentor_action, track: js

    discussions = Solution::MentorDiscussion::Retrieve.(user, page: 1)
    assert_equal [ruby], discussions.tracks
  end

  test "pagination works" do
    user = create :user

    25.times { create :solution_mentor_discussion, :requires_mentor_action, mentor: user }

    requests = Solution::MentorDiscussion::Retrieve.(user, page: 2)
    assert_equal 2, requests.current_page
    assert_equal 3, requests.total_pages
    assert_equal 10, requests.limit_value
    assert_equal 25, requests.total_count
  end
end
