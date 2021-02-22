require "test_helper"

class User::BecomeMentorTest < ActiveSupport::TestCase
  test "creates correctly" do
    user = create :user, :not_mentor
    create :track, slug: :ruby
    fsharp = create :track, slug: :fsharp
    csharp = create :track, slug: :csharp

    User::BecomeMentor.(user, %w[csharp fsharp])
    assert user.mentor?
    assert_equal [csharp, fsharp], user.mentored_tracks
  end

  test "skips if user is a mentor already" do
    old_time = Time.current - 1.week
    user = create :user, became_mentor_at: old_time

    User::BecomeMentor.(user, [create(:track).slug])
    assert user.mentor?
    assert_equal old_time, user.reload.became_mentor_at
  end

  test "fails with invalid track" do
    user = create :user, :not_mentor
    create :track, slug: :fsharp

    assert_raises InvalidTrackSlugsError do
      User::BecomeMentor.(user, %w[fsharp csharp])
    end
  end

  test "fails without tracks" do
    user = create :user, :not_mentor
    create :track, slug: :ruby
    create :track, slug: :fsharp
    create :track, slug: :csharp

    assert_raises MissingTracksError do
      User::BecomeMentor.(user, [])
    end
  end
end
