require "test_helper"

class Exercise::SearchTest < ActiveSupport::TestCase
  test "filters by track" do
    track = create :track, slug: "js"
    concept_exercise = create :concept_exercise, track: track
    practice_exercise = create :practice_exercise, track: track

    # Create on a different rack
    create :concept_exercise

    assert_equal [concept_exercise, practice_exercise], Exercise::Search.(track)
  end

  test "criteria" do
    track = create :track
    food = create :concept_exercise, title: "Food Chain", track: track
    bob = create :concept_exercise, title: "Bob", track: track

    assert_equal [food, bob], Exercise::Search.(track)
    assert_equal [food, bob], Exercise::Search.(track, criteria: " ")
    assert_equal [food], Exercise::Search.(track, criteria: "fo")
    assert_equal [bob], Exercise::Search.(track, criteria: "bo")
  end
end
