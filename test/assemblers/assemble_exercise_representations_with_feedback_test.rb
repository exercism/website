require "test_helper"

class AssembleExerciseRepresentationsWithFeedbackTest < ActiveSupport::TestCase
  test "index should return top 20 serialized correctly" do
    user = create :user
    representations = Array.new(25) do |idx|
      create :exercise_representation, num_submissions: 25 - idx, feedback_type: :actionable, feedback_author: user
    end

    paginated_representations = Kaminari.paginate_array(representations, total_count: 25).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      meta: {
        unscoped_total: 25
      }
    )

    assert_equal expected, AssembleExerciseRepresentationsWithFeedback.(user, {})
  end

  test "should proxy correctly" do
    track = create :track
    mentor = create :user
    criteria = 'bob'
    order = 'num_submissions'
    page = '1'

    Exercise::Representation::Search.expects(:call).with(
      mentor:,
      track:,
      status: :with_feedback,
      page:,
      order:,
      criteria:
    ).returns(Exercise::Representation.page(1).per(20))

    AssembleExerciseRepresentationsWithFeedback.(mentor, { track_slug: track.slug, criteria:, order:, page: })
  end
end
