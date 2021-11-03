require "test_helper"

class Search::IndexSolutionTest < ActiveSupport::TestCase
  test "indexes solution" do
    solution = create :solution

    Search::IndexSolution.(solution)
  end
end
