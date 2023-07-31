require "test_helper"

class Exercise::MarkSolutionsAsOutOfDateInIndexTest < ActiveSupport::TestCase
  test "mark all solutions of an exercise as out of date in index" do
    track = create :track, slug: 'fsharp'
    user_1 = create :user
    user_2 = create :user
    exercise_1 = create(:practice_exercise, id: 7, track:)
    exercise_2 = create(:practice_exercise, id: 8, track:)
    solution_1 = create :practice_solution, exercise: exercise_1, user: user_1, git_important_files_hash: 'different-hash'
    solution_2 = create :practice_solution, exercise: exercise_1, user: user_2,
      git_important_files_hash: exercise_1.git_important_files_hash
    solution_3 = create :practice_solution, exercise: exercise_2, user: user_1,
      git_important_files_hash: exercise_2.git_important_files_hash
    solution_4 = create :practice_solution, exercise: exercise_2, user: user_2

    wait_for_opensearch_to_be_synced

    # Sanity check
    assert out_of_date_in_index?(solution_1)
    refute out_of_date_in_index?(solution_2)
    refute out_of_date_in_index?(solution_3)
    refute out_of_date_in_index?(solution_4)

    wait_for_opensearch_to_be_synced

    Exercise::MarkSolutionsAsOutOfDateInIndex.(exercise_1)

    assert out_of_date_in_index?(solution_1)
    assert out_of_date_in_index?(solution_2)
    refute out_of_date_in_index?(solution_3)
    refute out_of_date_in_index?(solution_4)
  end

  private
  def out_of_date_in_index?(solution)
    doc = get_opensearch_doc(Solution::OPENSEARCH_INDEX, solution.id)
    doc["_source"]["out_of_date"]
  end
end
