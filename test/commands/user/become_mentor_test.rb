require "test_helper"

class User::BecomeMentorTest < ActiveSupport::TestCase
  test "creates correctly" do
    stub_request(:post, "https://dev.null.exercism.io/")

    user = create :user, :not_mentor, reputation: User::MIN_REP_TO_MENTOR
    create :track, slug: :ruby
    csharp = create :track, slug: :csharp
    fsharp = create :track, slug: :fsharp

    User::BecomeMentor.(user, %w[csharp fsharp])
    assert user.mentor?
    assert_equal [csharp, fsharp], user.mentored_tracks.sort
  end

  test "skips if user is a mentor already" do
    old_time = Time.current - 1.week
    user = create :user, reputation: User::MIN_REP_TO_MENTOR
    user.update(became_mentor_at: old_time)

    User::BecomeMentor.(user, [create(:track).slug])
    assert user.mentor?
    assert_equal old_time, user.reload.became_mentor_at
  end

  test "skips if user doesnt have enough reps" do
    user = create :user, :not_mentor, reputation: 19

    User::BecomeMentor.(user, [create(:track).slug])
    refute user.mentor?
  end

  test "fails with invalid track" do
    user = create :user, :not_mentor, reputation: User::MIN_REP_TO_MENTOR
    create :track, slug: :fsharp

    assert_raises InvalidTrackSlugsError do
      User::BecomeMentor.(user, %w[fsharp csharp])
    end
  end

  test "fails without tracks" do
    user = create :user, :not_mentor, reputation: User::MIN_REP_TO_MENTOR
    create :track, slug: :ruby
    create :track, slug: :fsharp
    create :track, slug: :csharp

    assert_raises MissingTracksError do
      User::BecomeMentor.(user, [])
    end
  end
end
