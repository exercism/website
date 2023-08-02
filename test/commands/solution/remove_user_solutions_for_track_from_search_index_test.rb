require "test_helper"

class Solution::RemoveUserSolutionsForTrackFromSearchIndexTest < ActiveSupport::TestCase
  test "remove solutions from search index" do
    user = create :user
    other_user = create :user
    track = create :track, :random_slug
    other_track = create :track, :random_slug

    user_track_1 = create(:user_track, user:, track:)
    create :user_track, user:, track: other_track
    create(:user_track, user: other_user, track:)

    ce_track = create(:concept_exercise, track:)
    pe_track = create(:practice_exercise, track:)
    pe_other_track = create :practice_exercise, track: other_track

    solution_1 = create(:concept_solution, exercise: ce_track, user:)
    solution_2 = create(:practice_solution, exercise: pe_track, user:)
    solution_3 = create(:practice_solution, exercise: pe_other_track, user:)
    solution_4 = create(:practice_solution, exercise: ce_track, user: other_user)

    Solution::SyncToSearchIndex.(solution_1)
    Solution::SyncToSearchIndex.(solution_2)
    Solution::SyncToSearchIndex.(solution_3)
    Solution::SyncToSearchIndex.(solution_4)

    wait_for_opensearch_to_be_synced

    refute_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution_1.id)
    refute_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution_2.id)
    refute_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution_3.id)
    refute_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution_4.id)

    Solution::RemoveUserSolutionsForTrackFromSearchIndex.(user_track_1.user_id, user_track_1.track_id)

    wait_for_opensearch_to_be_synced
    assert_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution_1.id)
    assert_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution_2.id)
    refute_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution_3.id)
    refute_nil get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution_4.id)
  end
end
