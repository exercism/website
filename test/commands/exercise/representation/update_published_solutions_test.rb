require "test_helper"

class Exercise::Representation::UpdatePublishedSolutionsTest < ActiveSupport::TestCase
  test "updates num solutions" do
    representation = create :exercise_representation
    create(:practice_solution)
    create(:practice_solution, published_exercise_representation: create(:exercise_representation))
    create(:practice_solution, published_exercise_representation: representation)
    create(:practice_solution, published_exercise_representation: representation)

    assert_equal 0, representation.num_published_solutions

    Exercise::Representation::UpdatePublishedSolutions.(representation)

    assert_equal 2, representation.num_published_solutions
  end

  test "syncs to search index" do
    representation = create :exercise_representation
    Exercise::Representation::SyncToSearchIndex.expects(:defer).with(representation)

    Exercise::Representation::UpdatePublishedSolutions.(representation)
  end
end
