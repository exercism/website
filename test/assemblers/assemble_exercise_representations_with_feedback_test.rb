require "test_helper"

class AssembleExerciseRepresentationsWithFeedbackTest < ActiveSupport::TestCase
  test "index should return top 20 serialized correctly" do
    track = create :track
    user = create :user
    representations = Array.new(25) do |idx|
      create(:exercise_representation, num_submissions: 25 - idx, feedback_type: :actionable, feedback_author: user,
        last_submitted_at: Time.utc(2022, 3, 15) - idx.days, track:)
    end
    params = { track_slug: track.slug }

    paginated_representations = Kaminari.paginate_array(representations, total_count: 24).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      serializer_kwargs: { params: },
      meta: {
        unscoped_total: 25
      }
    )

    assert_equal expected, AssembleExerciseRepresentationsWithFeedback.(user, params)
  end

  test "should select correct representer version" do
    track = create :track
    mentor = create :user
    create :exercise_representation, track:, representer_version: 2
    create :exercise_representation, track:, representer_version: 5
    create :exercise_representation, track:, representer_version: 1

    Exercise::Representation::Search.expects(:call).with do |kwargs|
      assert_equal 5, kwargs[:representer_version]
    end.returns(Exercise::Representation.page(1).per(20))

    AssembleExerciseRepresentationsWithFeedback.(mentor, { track_slug: track.slug })
  end

  test "should proxy correctly" do
    track = create :track
    mentor = create :user
    criteria = 'bob'
    order = 'num_submissions'
    page = '1'

    Exercise::Representation::Search.expects(:call).with(
      mode: :with_feedback,
      representer_version: 1,
      mentor:,
      track:,
      page:,
      order:,
      criteria:
    ).returns(Exercise::Representation.page(1).per(20))

    AssembleExerciseRepresentationsWithFeedback.(mentor, { track_slug: track.slug, criteria:, order:, page: })
  end
end
