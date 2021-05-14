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

  test "ace_language" do
    track = create :track
    assert_equal 'ruby', track.ace_language
  end

  test "highlightjs_language" do
    track = create :track
    assert_equal 'ruby', track.highlightjs_language
  end

  test "average_test_run_time" do
    track = create :track
    assert_equal 2.2, track.average_test_run_time
  end

  test "Retrieves test_regexp for track with test regex" do
    track = create :track
    assert_equal(/test/, track.test_regexp)
  end

  test "Retrieves test_regexp for track without test regex" do
    track = create :track, repo_url: TestHelpers.git_repo_url("track-naked")
    assert_equal(/[tT]est/, track.test_regexp)
  end

  test "Retrieves ignore_regexp for track with ignore regex" do
    track = create :track
    assert_equal(/[iI]gno/, track.ignore_regexp)
  end

  test "Retrieves ignore_regexp for track without ignore regex" do
    track = create :track, repo_url: TestHelpers.git_repo_url("track-naked")
    assert_equal(/[iI]gnore/, track.ignore_regexp)
  end

  test "top_10_contributors" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user
    track = create :track

    create :user_code_contribution_reputation_token, track: track, user: user_1
    create :user_code_contribution_reputation_token, track: track, user: user_2
    create :user_code_contribution_reputation_token, track: track, user: user_2
    create :user_code_contribution_reputation_token, user: user_3

    assert_equal [user_2, user_1], track.top_10_contributors
  end

  test "num_contributors" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user
    track = create :track

    create :user_code_contribution_reputation_token, track: track, user: user_1
    create :user_code_contribution_reputation_token, track: track, user: user_2
    create :user_code_contribution_reputation_token, track: track, user: user_2
    create :user_code_contribution_reputation_token, user: user_3

    assert_equal 2, track.num_contributors
  end

  test "num_code_contributors" do
    user_1 = create :user
    user_2 = create :user
    user_3 = create :user
    track = create :track

    create :user_code_contribution_reputation_token, track: track, user: user_1
    create :user_code_merge_reputation_token, track: track, user: user_2
    create :user_code_contribution_reputation_token, track: track, user: user_2
    create :user_code_review_reputation_token, track: track, user: user_3
    create :user_exercise_contribution_reputation_token, track: track, user: user_3
    create :user_exercise_author_reputation_token, track: track, user: user_3
    create :user_code_contribution_reputation_token, user: user_3

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
end
