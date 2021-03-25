require 'test_helper'

class Mentor::Discussion::RetrieveTest < ActiveSupport::TestCase
  test "only retrieves user's solutions" do
    user = create :user

    valid = create :mentor_discussion, :requires_mentor_action, mentor: user
    create :mentor_discussion, :requires_mentor_action

    assert_equal [valid], Mentor::Discussion::Retrieve.(user, page: 1)
  end

  test "only retrieves solutions requiring action" do
    user = create :user

    valid = create :mentor_discussion, :requires_mentor_action, mentor: user
    create :mentor_discussion, mentor: user

    assert_equal [valid], Mentor::Discussion::Retrieve.(user, page: 1)
  end

  test "only retrieves relevant tracks" do
    user = create :user
    ruby = create :track, slug: :ruby
    js = create :track, slug: :js
    elixir = create :track, slug: :elixir

    create :mentor_discussion, :requires_mentor_action, track: ruby, mentor: user
    create :mentor_discussion, :requires_mentor_action, track: elixir, mentor: user
    create :mentor_discussion, :requires_mentor_action, track: js

    assert_equal [ruby, elixir], Mentor::Discussion::Retrieve.(user).map(&:track)
    assert_equal [ruby, elixir], Mentor::Discussion::Retrieve.(user, track_slug: '').map(&:track)
    assert_equal [ruby], Mentor::Discussion::Retrieve.(user, track_slug: 'ruby').map(&:track)
  end

  test "orders by requires_mentor_action_since" do
    user = create :user

    second = create :mentor_discussion, requires_mentor_action_since: Time.current - 2.minutes, mentor: user
    first = create :mentor_discussion, requires_mentor_action_since: Time.current - 3.minutes, mentor: user
    third = create :mentor_discussion, requires_mentor_action_since: Time.current - 1.minute, mentor: user

    assert_equal [first, second, third], Mentor::Discussion::Retrieve.(user)
    assert_equal [second, first, third], Mentor::Discussion::Retrieve.(user, sorted: false)
  end

  test "pagination works" do
    user = create :user

    25.times { create :mentor_discussion, :requires_mentor_action, mentor: user }

    requests = Mentor::Discussion::Retrieve.(user, page: 2)
    assert_equal 2, requests.current_page
    assert_equal 3, requests.total_pages
    assert_equal 10, requests.limit_value
    assert_equal 25, requests.total_count
  end

  test "returns relationship unless paginated" do
    mentored_track = create :track
    user = create :user

    solution = create :concept_solution, track: mentored_track

    create :mentor_request, solution: solution

    requests = Mentor::Discussion::Retrieve.(user, paginated: false)
    assert requests.is_a?(ActiveRecord::Relation)
    refute_respond_to requests, :current_page
  end
end
