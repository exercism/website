require "test_helper"

class User::ReputationTokens::MentoredTokenTest < ActiveSupport::TestCase
  test "creates successfully" do
    mentor = create :user
    discussion = create(:mentor_discussion, :mentor_finished, mentor:)
    student = discussion.solution.user
    exercise = discussion.solution.exercise

    User::ReputationToken::Create.(
      mentor,
      :mentored,
      discussion:
    )

    assert_equal 1, mentor.reputation_tokens.size
    rt = mentor.reputation_tokens.first

    assert_instance_of User::ReputationTokens::MentoredToken, rt
    assert_equal "You mentored <strong>#{student.handle}</strong> on <strong>#{exercise.title}</strong> in <strong>#{exercise.track.title}</strong>", rt.text # rubocop:disable Layout/LineLength
    assert_equal "#{mentor.id}|mentored|Discussion##{discussion.id}", rt.uniqueness_key
    assert_equal :mentoring, rt.category
    assert_equal :mentored, rt.reason
    assert_equal 5, rt.value
    assert_equal discussion.finished_at.to_date, rt.earned_on
    assert_equal Exercism::Routes.mentoring_discussion_url(discussion), rt.rendering_data[:internal_url]
    assert_equal discussion.track, rt.track
    assert_equal discussion.exercise, rt.exercise
  end
end
