require "test_helper"

class CommunityVideo::CreateTest < ActiveSupport::TestCase
  test "creates correctly" do
    url = mock
    title = "Foobar"
    submitter = create :user
    author = create :user
    exercise = create :practice_exercise
    retrieved_video = build :community_video
    CommunityVideo::Retrieve.expects(:call).with(url).returns(retrieved_video)

    video = CommunityVideo::Create.(
      url,
      submitter,
      title:,
      author:,
      track: exercise.track,
      exercise:
    )

    assert video.persisted?
    assert_equal author, video.author
    assert_equal title, video.title
    assert_equal submitter, video.submitted_by
    assert_equal exercise.track, video.track
    assert_equal exercise, video.exercise
  end

  test "defaults to video title" do
    url = mock
    submitter = create :user
    title = "Something"
    retrieved_video = build(:community_video, title:)
    CommunityVideo::Retrieve.expects(:call).with(url).returns(retrieved_video)

    video = CommunityVideo::Create.(url, submitter)

    assert video.persisted?
    assert_equal title, video.title
  end

  test "raises when video already exists" do
    url = mock
    exercise = create :practice_exercise
    video = create(:community_video, url:, exercise:)
    retrieved_video = build(:community_video, url:, exercise:)

    CommunityVideo::Retrieve.expects(:call).with(video.url).returns(retrieved_video)

    assert_raises(DuplicateVideoError) do
      CommunityVideo::Create.(
        retrieved_video.url,
        retrieved_video.submitted_by,
        title: retrieved_video.title,
        author: retrieved_video.author,
        track: retrieved_video.exercise.track,
        exercise: retrieved_video.exercise
      )
    end
  end
end
