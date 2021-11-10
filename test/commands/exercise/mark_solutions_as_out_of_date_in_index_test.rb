require "test_helper"

class Exercise::MarkSolutionsAsOutOfDateInIndexTest < ActiveSupport::TestCase
  SOLUTIONS_INDEX = 'test-solutions'.freeze

  test "mark all solutions of an exercise as out of date in index" do
    # Start by removing any existing solutions
    Exercism.opensearch_client.delete_by_query(index: SOLUTIONS_INDEX, body: {
      query: { match_all: {} }
    })

    track = create :track, slug: 'fsharp'
    user_1 = create :user
    user_2 = create :user
    exercise_1 = create :practice_exercise, id: 7, track: track
    exercise_2 = create :practice_exercise, id: 8, track: track
    solution_1 = create :practice_solution, exercise: exercise_1, user: user_1, git_important_files_hash: 'different-hash'
    solution_2 = create :practice_solution, exercise: exercise_1, user: user_2,
git_important_files_hash: exercise_1.git_important_files_hash
    solution_3 = create :practice_solution, exercise: exercise_2, user: user_1,
git_important_files_hash: exercise_2.git_important_files_hash
    solution_4 = create :practice_solution, exercise: exercise_2, user: user_2

    # Solutions are automatically indexed via a job in the background
    perform_enqueued_jobs

    # Sanity check
    assert out_of_date_in_index?(solution_1)
    refute out_of_date_in_index?(solution_2)
    refute out_of_date_in_index?(solution_3)
    refute out_of_date_in_index?(solution_4)

    # Force an index refresh to ensure there are no concurrent actions in the background
    Exercism.opensearch_client.indices.refresh(index: SOLUTIONS_INDEX)

    Exercise::MarkSolutionsAsOutOfDateInIndex.(exercise_1)

    assert out_of_date_in_index?(solution_1)
    assert out_of_date_in_index?(solution_2)
    refute out_of_date_in_index?(solution_3)
    refute out_of_date_in_index?(solution_4)
  end

  private
  def out_of_date_in_index?(solution)
    doc = Exercism.opensearch_client.get(index: SOLUTIONS_INDEX, id: solution.id)
    doc["_source"]["out_of_date"]
  end
end
