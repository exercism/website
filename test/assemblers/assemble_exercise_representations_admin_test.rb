require "test_helper"

class AssembleExerciseRepresentationsAdminTest < ActiveSupport::TestCase
  test "index should return top 20 serialized correctly" do
    user = create :user
    representations = Array.new(25) do |idx|
      create :exercise_representation, num_submissions: 25 - idx, feedback_type: :actionable, feedback_author: user,
        last_submitted_at: Time.utc(2022, 3, 15) - idx.days
    end
    params = {}

    paginated_representations = Kaminari.paginate_array(representations, total_count: 24).page(1).per(20)
    expected = SerializePaginatedCollection.(
      paginated_representations,
      serializer: SerializeExerciseRepresentations,
      serializer_kwargs: { params: },
      meta: {
        unscoped_total: 25
      }
    )

    assert_equal expected, AssembleExerciseRepresentationsAdmin.(params)
  end

  test "should proxy correctly" do
    track = create :track
    criteria = 'bob'
    order = 'num_submissions'
    page = '1'

    Exercise::Representation::Search.expects(:call).with(
      with_feedback: true,
      track:,
      page:,
      order:,
      criteria:
    ).returns(Exercise::Representation.page(1).per(20))

    AssembleExerciseRepresentationsAdmin.({ track_slug: track.slug, criteria:, order:, page: })
  end
end
