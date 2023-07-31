require "test_helper"

class AssembleExerciseRepresentationsAdminTest < ActiveSupport::TestCase
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

    assert_equal expected, AssembleExerciseRepresentationsAdmin.(user, params)
  end

  test "should proxy correctly" do
    track = create :track
    user = create :user
    criteria = 'bob'
    order = 'most_recent_feedback'
    page = '1'

    Exercise::Representation::Search.expects(:call).with(
      mentor: user,
      track:,
      mode: :admin,
      only_mentored_solutions: nil,
      criteria:,
      page:,
      order:
    ).returns(Exercise::Representation.page(1).per(20))

    AssembleExerciseRepresentationsAdmin.(user, { track_slug: track.slug, criteria:, order:, page: })
  end
end
