require 'test_helper'

class TrackTest < ActiveSupport::TestCase
  test ".for! with model" do
    track = random_of_many(:track)
    assert_equal track, Track.for!(track)
  end

  test ".for! with id" do
    track = random_of_many(:track)
    assert_equal track, Track.for!(track.id)
  end

  test ".for! with slug" do
    track = random_of_many(:track)
    assert_equal track, Track.for!(track.slug)
  end

  test ".active scope" do
    # Create one active and one inactive track
    track = create :track, active: true
    create :track, :random_slug, active: false

    assert_equal [track], Track.active
  end

  test "to_slug" do
    track = create :track
    assert_equal track.slug, track.to_param
  end

  test "highlightjs_language" do
    track = create :track
    assert_equal 'ruby', track.highlightjs_language
  end

  test "average_test_duration" do
    track = create :track
    assert_equal 2.2, track.average_test_duration
  end

  test "top_contributors" do
    track = create :track
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user

    # Random users
    20.times { create :user_reputation_period, about: :track, track_id: track.id, reputation: 5 }

    create :user_reputation_period, about: :track, track_id: track.id, user: user_1, reputation: 10
    create :user_reputation_period, about: :track, track_id: track.id, user: user_2, reputation: 20

    # Other inconsequential rows
    create :user_reputation_period, about: :track, period: :year, track_id: track.id, user: user_3, reputation: 20
    create :user_reputation_period, about: :everything, user: user_3, reputation: 20
    create :user_reputation_period, about: :track, track_id: track.id + 1, user: user_3, reputation: 20

    assert_equal [user_2, user_1], track.top_contributors[0, 2]
    assert_equal 20, track.top_contributors.size
  end

  test "num_contributors" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user
    track = create :track

    create :user_reputation_period, about: :track, track_id: track.id, user: user_1, reputation: 10
    create :user_reputation_period, about: :track, track_id: track.id, user: user_2, reputation: 20

    # Other inconsequential rows
    create :user_reputation_period, about: :track, period: :year, track_id: track.id, user: user_3, reputation: 20
    create :user_reputation_period, about: :everything, user: user_3, reputation: 20
    create :user_reputation_period, about: :track, track_id: track.id + 1, user: user_3, reputation: 20

    assert_equal 2, track.num_contributors
  end

  test "num_code_contributors" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user
    track = create :track

    create :user_reputation_period, category: :building, about: :track, track_id: track.id, user: user_1, reputation: 10
    create :user_reputation_period, category: :building, about: :track, track_id: track.id, user: user_2, reputation: 20

    # Other inconsequential rows
    create :user_reputation_period, category: :any, about: :track, track_id: track.id, user: user_3, reputation: 30
    create :user_reputation_period, category: :maintaining, about: :track, track_id: track.id, user: user_3, reputation: 30
    create :user_reputation_period, about: :track, period: :year, track_id: track.id, user: user_3, reputation: 20
    create :user_reputation_period, about: :everything, user: user_3, reputation: 20
    create :user_reputation_period, about: :track, track_id: track.id + 1, user: user_3, reputation: 20

    assert_equal 2, track.num_code_contributors
  end

  test "num_mentors" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user
    user_4 = create :user
    track_1 = create :track
    track_2 = create :track, slug: 'fsharp'

    create :user_track_mentorship, track: track_1, user: user_1
    create :user_track_mentorship, track: track_1, user: user_2
    create :user_track_mentorship, track: track_1, user: user_3
    create :user_track_mentorship, track: track_2, user: user_4

    assert_equal 3, track_1.num_mentors
  end

  test "course? is false when concept_exercises status is false" do
    track = create :track

    git_track = Git::Track.new("HEAD", repo_url: track.repo_url)
    config = git_track.config
    config[:status][:concept_exercises] = false

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    refute track.course?
  end

  test "course? is true when concept_exercises status is true" do
    track = create :track

    git_track = Git::Track.new("HEAD", repo_url: track.repo_url)
    config = git_track.config
    config[:status][:concept_exercises] = true

    Mocha::Configuration.override(stubbing_non_public_method: :allow) do
      Git::Track.any_instance.stubs(:config).returns(config)
    end

    assert track.course?
  end

  test "repo_name" do
    track = create :track, slug: 'ruby'

    assert_equal 'exercism/ruby', track.repo_name
  end
end
