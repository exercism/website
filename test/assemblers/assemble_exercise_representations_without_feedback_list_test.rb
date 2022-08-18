require "test_helper"

class AssembleExerciseRepresentationsWithoutFeedbackListTest < ActiveSupport::TestCase
  test "index should return top 20 serialized correctly" do
    track = create :track
    user = create :user
    create :user_track_mentorship, user: user, track: track
    exercise = create :practice_exercise, track: track
    representations = Array.new(25) do |idx|
      create :exercise_representation, num_submissions: 25 - idx, feedback_type: nil, exercise: exercise
    end

    paginated_representations = Kaminari.paginate_array(representations, total_count: 25).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      meta: {
        unscoped_total: 25
      }
    )

    assert_equal expected, AssembleExerciseRepresentationsWithoutFeedbackList.(user, {})
  end

  test "should proxy correctly" do
    track = create :track
    user = create :user
    criteria = 'bob'
    order = 'num_submissions'
    page = '1'

    Exercise::Representation::Search.expects(:call).with(
      status: :without_feedback,
      user:,
      track:,
      page:,
      order:,
      criteria:
    ).returns(Exercise::Representation.page(1).per(20))

    AssembleExerciseRepresentationsWithoutFeedbackList.(user, track_slug: track.slug, criteria:, order:, page:)
  end

  test "should proxy correctly when track_slug is not specified" do
    user = create :user
    criteria = 'bob'
    order = 'num_submissions'
    page = '1'

    Exercise::Representation::Search.expects(:call).with(
      status: :without_feedback,
      user:,
      page:,
      order:,
      criteria:,
      track: nil
    ).returns(Exercise::Representation.page(1).per(20))

    AssembleExerciseRepresentationsWithoutFeedbackList.(user, criteria:, order:, page:)
  end
end
