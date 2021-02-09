require 'test_helper'

class SerializeTracksTest < ActiveSupport::TestCase
  test "without user" do
    tags = ["Foo: Bar", "Abc: Xyz"]
    track = create :track, tags: tags

    num_concept_exercises = 3
    num_concepts = num_concept_exercises + 1
    num_practice_exercises = 7

    # Create num_concept_exercises, each with a concept
    # and then add one extra concept to the last exercise
    num_concept_exercises.times do
      create(:track_concept, track: track)
      create(:concept_exercise, track: track)
    end
    create(:track_concept, track: track)

    # Create num_practice_exercises practice exercises
    num_practice_exercises.times { create :practice_exercise, track: track }

    expected = {
      tracks: [
        {
          id: track.id,
          title: track.title,
          num_concepts: num_concepts,
          num_concept_exercises: num_concept_exercises,
          num_practice_exercises: num_practice_exercises,
          web_url: "https://test.exercism.io/tracks/#{track.slug}",

          # TODO: Set all three of these
          icon_url: "https://assets.exercism.io/tracks/ruby-hex-white.png",
          is_new: true,
          tags: tags,
          updated_at: track.updated_at
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

    num_concept_exercises = 4
    num_practice_exercises = 7

    # Create num_concept_exercises, each with a concept
    # and then add one extra concept to the last exercise
    ces = Array.new(num_concept_exercises).map { create(:concept_exercise, track: track) }

    # Create num_practice_exercises practice exercises
    pes = Array.new(num_practice_exercises).map { create :practice_exercise, track: track }

    # Create a concept that the user has acquired
    concept = create(:track_concept, track: track)

    user = create :user
    user_track = create :user_track, user: user, track: track

    # TODO: Change to be completed when that is in the db schema
    # and add a case where it's not completed to check the flag is
    # being used correctly.
    create :concept_solution, exercise: ces[0], user: user
    create :concept_solution, exercise: ces[1], user: user
    create :practice_solution, exercise: pes[0], user: user
    create :practice_solution, exercise: pes[1], user: user
    create :practice_solution, exercise: pes[2], user: user
    create :user_track_learnt_concept, user_track: user_track, concept: concept

    output = SerializeTracks.([track], user)

    track_data = output[:tracks].first
    assert track_data[:is_joined]
    assert_equal 1, track_data[:num_learnt_concepts]
    assert_equal 2, track_data[:num_completed_concept_exercises]
    assert_equal 3, track_data[:num_completed_practice_exercises]
  end

  test "tags are always an array" do
    track = create :track, tags: nil
    output = SerializeTracks.([track])

    track_data = output[:tracks].first
    assert_equal [], track_data[:tags]
  end

  test "sorts by name" do
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "Javascript", slug: :js
    assembly = create :track, title: "Assembly", slug: :ass
    rust = create :track, title: "Rust", slug: :rust

    expected = %w[Assembly Javascript Ruby Rust]
    actual = SerializeTracks.(
      [ruby, javascript, assembly, rust]
    )[:tracks].map { |t| t[:title] }
    assert_equal expected, actual
  end

  test "sorts by joined then name" do
    ruby = create :track, title: "Ruby"
    javascript = create :track, title: "Javascript", slug: :js
    assembly = create :track, title: "Assembly", slug: :ass
    rust = create :track, title: "Rust", slug: :rust

    user = create :user
    create :user_track, user: user, track: rust

    expected = %w[Rust Assembly Javascript Ruby]
    actual = SerializeTracks.(
      [ruby, javascript, assembly, rust],
      user
    )[:tracks].map { |t| t[:title] }
    assert_equal expected, actual
  end
end
