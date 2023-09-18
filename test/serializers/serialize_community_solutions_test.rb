require 'test_helper'

class SerializeCommunitySolutionsTest < ActiveSupport::TestCase
  test "basic test" do
    solution = create :concept_solution

    expected = [
      SerializeCommunitySolution.(solution)
    ]

    assert_equal expected, SerializeCommunitySolutions.(
      Solution.all
    )
  end

  test "n+1s handled correctly" do
    create_np1_data

    Bullet.profile do
      SerializeCommunitySolutions.(Solution.all)
    end
  end
end
