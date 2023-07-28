require 'test_helper'

class Mentor::Request::RetrieveExercisesTest < ActiveSupport::TestCase
  test "retrieves correctly" do
    user = create :user

    ruby = create :track, slug: "ruby", title: "Ruby"
    csharp = create :track, slug: "csharp", title: "C#"

    # This shouldn't be included
    strings = create :concept_exercise, track: ruby

    # These are csharp and should be included
    zipper = create :concept_exercise, track: csharp, slug: :zipper, title: "Zipper"
    bob = create :practice_exercise, track: csharp, slug: :bob, title: "Bob"
    fred = create :practice_exercise, track: csharp, slug: :fred, title: "Fred"

    # Make some requests for each except fred
    3.times { create :mentor_request, solution: create(:concept_solution, exercise: strings) }
    2.times { create :mentor_request, solution: create(:concept_solution, exercise: zipper) }
    4.times { create :mentor_request, solution: create(:concept_solution, exercise: bob) }

    # Create mentor solutions to fred and zipper, with zipper completed
    create :concept_solution, user:, exercise: fred
    create :concept_solution, user:, exercise: zipper, completed_at: Time.current

    expected = [
      {
        slug: "bob",
        title: "Bob",
        icon_url: bob.icon_url,
        count: 4,
        completed_by_mentor: false
      },
      {
        slug: "fred",
        title: "Fred",
        icon_url: fred.icon_url,
        count: 0,
        completed_by_mentor: false
      },
      {
        slug: "zipper",
        title: "Zipper",
        icon_url: zipper.icon_url,
        count: 2,
        completed_by_mentor: true
      }

    ]
    actual = Mentor::Request::RetrieveExercises.(user, "csharp")
    assert_equal expected, actual
  end
end
