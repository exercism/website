require 'test_helper'

class SerializeTracksTest < ActiveSupport::TestCase
  test "without user" do
    tags = ["Foo: Bar", "Abc: Xyz"]
    track = create :track, tags: tags

    num_concept_exercises = 3
    num_practice_exercises = 7

    num_concept_exercises.times { create :concept_exercise, track: track }
    num_practice_exercises.times { create :practice_exercise, track: track }

    expected = {
      tracks: [
        {
          id: track.id,
          title: track.title,
          num_concept_exercises: num_concept_exercises,
          num_practice_exercises: num_practice_exercises,
          web_url: "https://test.exercism.io/tracks/#{track.slug}",

          # TODO: Set all three of these
          icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
          is_new: true,
          tags: tags
        }
      ]
    }

    assert_equal expected, SerializeTracks.([track])
  end

  test "with user not joined" do
    track = create :track

    output = SerializeTracks.([track], create(:user))

    track_data = output[:tracks].first
    refute track_data[:is_joined]
    assert_equal 0, track_data[:num_completed_concept_exercises]
    assert_equal 0, track_data[:num_completed_practice_exercises]
  end

  test "with user joined and progressed" do
    track = create :track
    ces = Array.new(3).map { create :concept_exercise, track: track }
    pes = Array.new(3).map { create :practice_exercise, track: track }

    user = create :user
    create :user_track, user: user, track: track

    # TODO: Change to be completed when that is in the db schema
    # and add a case where it's not completed to check the flag is
    # being used correctly.
    create :concept_solution, exercise: ces[0], user: user
    create :practice_solution, exercise: pes[0], user: user
    create :practice_solution, exercise: pes[1], user: user

    output = SerializeTracks.([track], user)

    track_data = output[:tracks].first
    assert track_data[:is_joined]
    assert_equal 1, track_data[:num_completed_concept_exercises]
    assert_equal 2, track_data[:num_completed_practice_exercises]
  end
end
