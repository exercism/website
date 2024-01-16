require "test_helper"

class AssembleExerciseRepresentationsAdminTest < ActiveSupport::TestCase
  test "index should return top 20 serialized correctly" do
    track = create :track
    user = create :user
    representations = Array.new(25) do |idx|
      create(:exercise_representation, num_submissions: 25 - idx, feedback_type: :actionable, feedback_author: user,
        feedback_added_at: Time.utc(2022, 3, 15) - idx.days, track:)
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

  test "should select correct representer version" do
    track = create :track
    mentor = create :user
    create :exercise_representation, track:, representer_version: 2
    create :exercise_representation, track:, representer_version: 5
    create :exercise_representation, track:, representer_version: 1

    Exercise::Representation::Search.expects(:call).with do |kwargs|
      assert_equal 5, kwargs[:representer_version]
    end.returns(Exercise::Representation.page(1).per(20))

    AssembleExerciseRepresentationsAdmin.(mentor, { track_slug: track.slug })
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
      representer_version: 1,
      only_mentored_solutions: nil,
      criteria:,
      page:,
      order:
    ).returns(Exercise::Representation.page(1).per(20))

    AssembleExerciseRepresentationsAdmin.(user, { track_slug: track.slug, criteria:, order:, page: })
  end
end
