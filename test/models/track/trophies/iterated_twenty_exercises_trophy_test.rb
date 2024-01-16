require "test_helper"

class Track::Trophies::IteratedTwentyExercisesTrophyTest < ActiveSupport::TestCase
  test "award?" do
    user = create :user
    track = create :track
    trophy = create :iterated_twenty_exercises_trophy

    exercises = create_list(:practice_exercise, 20, :random_slug, track:)
    create(:user_track, user:, track:)

    # We need to get hold of the user track like this as otherwise
    # we'd end up with the code being tested using a different,
    # cached version of the user track and we could not reset the
    # summary data
    user_track = UserTrack.for!(user, track)

    # Completing 20 solutions with just one iteration does not
    solutions = exercises.map do |exercise|
      create(:practice_solution, :completed, exercise:, user:).tap do |solution|
        create(:iteration, solution:)
      end
    end
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Adding a second iteration to 19 solutions does not count
    solutions[0..18].each do |solution|
      create :iteration, solution:
    end
    user_track.reset_summary!
    refute trophy.award?(user, track)

    # Add a second iteration to a 20th solution counts
    create :iteration, solution: solutions[19]
    user_track.reset_summary!
    assert trophy.award?(user, track)
  end

  test "worth_queuing?" do
    track = create :track
    trophy = create :iterated_twenty_exercises_trophy
    solution = create(:practice_solution, track:)
    iteration_1 = create(:iteration, solution:, idx: 1)

    # Don't queue first iteration
    refute trophy.worth_queuing?(track:, iteration: iteration_1)

    # Queue second iteration
    iteration_2 = create(:iteration, solution:, idx: 2)
    assert trophy.worth_queuing?(track:, iteration: iteration_2)
  end

  test "worth_queuing? does not require exercise in context" do
    track = create :track
    trophy = create :iterated_twenty_exercises_trophy

    assert trophy.worth_queuing?(track:)
  end
end
