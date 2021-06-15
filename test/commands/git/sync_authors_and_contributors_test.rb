require "test_helper"

class Git::SyncAuthorsAndContributorsTest < ActiveSupport::TestCase
  test "sync authors of all exercises" do
    track_1 = create :track, slug: 'ruby'
    track_2 = create :track, slug: 'csharp'
    track_3 = create :track, slug: 'elixir'

    exercise_1 = create :concept_exercise, track: track_1
    exercise_2 = create :concept_exercise, track: track_2
    exercise_3 = create :practice_exercise, track: track_2
    exercise_4 = create :practice_exercise, track: track_3

    Git::SyncExerciseAuthors.expects(:call).with(exercise_1)
    Git::SyncExerciseAuthors.expects(:call).with(exercise_2)
    Git::SyncExerciseAuthors.expects(:call).with(exercise_3)
    Git::SyncExerciseAuthors.expects(:call).with(exercise_4)

    Git::SyncAuthorsAndContributors.()
  end

  test "sync contributors of all exercises" do
    track_1 = create :track, slug: 'ruby'
    track_2 = create :track, slug: 'csharp'
    track_3 = create :track, slug: 'elixir'

    exercise_1 = create :concept_exercise, track: track_1
    exercise_2 = create :concept_exercise, track: track_2
    exercise_3 = create :practice_exercise, track: track_2
    exercise_4 = create :practice_exercise, track: track_3

    Git::SyncExerciseContributors.expects(:call).with(exercise_1)
    Git::SyncExerciseContributors.expects(:call).with(exercise_2)
    Git::SyncExerciseContributors.expects(:call).with(exercise_3)
    Git::SyncExerciseContributors.expects(:call).with(exercise_4)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing authors of other exercises when an error occurs" do
    track_1 = create :track, slug: 'ruby'
    track_2 = create :track, slug: 'csharp'
    track_3 = create :track, slug: 'elixir'

    exercise_1 = create :concept_exercise, track: track_1
    exercise_2 = create :concept_exercise, track: track_2
    exercise_3 = create :practice_exercise, track: track_2
    exercise_4 = create :practice_exercise, track: track_3

    Git::SyncExerciseAuthors.expects(:call).with(exercise_1).raises(RuntimeError)
    Git::SyncExerciseAuthors.expects(:call).with(exercise_2)
    Git::SyncExerciseAuthors.expects(:call).with(exercise_3)
    Git::SyncExerciseAuthors.expects(:call).with(exercise_4)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing contributors of other exercises when an error occurs" do
    track_1 = create :track, slug: 'ruby'
    track_2 = create :track, slug: 'csharp'
    track_3 = create :track, slug: 'elixir'

    exercise_1 = create :concept_exercise, track: track_1
    exercise_2 = create :concept_exercise, track: track_2
    exercise_3 = create :practice_exercise, track: track_2
    exercise_4 = create :practice_exercise, track: track_3

    Git::SyncExerciseContributors.expects(:call).with(exercise_1)
    Git::SyncExerciseContributors.expects(:call).with(exercise_2).raises(RuntimeError)
    Git::SyncExerciseContributors.expects(:call).with(exercise_3)
    Git::SyncExerciseContributors.expects(:call).with(exercise_4)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing contributors of exercise when authors syncing errors" do
    exercise = create :concept_exercise

    Git::SyncExerciseAuthors.expects(:call).with(exercise).raises(RuntimeError)
    Git::SyncExerciseContributors.expects(:call).with(exercise)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing authors of exercise when contributors syncing errors" do
    exercise = create :concept_exercise

    Git::SyncExerciseAuthors.expects(:call).with(exercise)
    Git::SyncExerciseContributors.expects(:call).with(exercise).raises(RuntimeError)

    Git::SyncAuthorsAndContributors.()
  end

  test "sync authors of all concepts" do
    track_1 = create :track, slug: 'ruby'
    track_2 = create :track, slug: 'csharp'
    track_3 = create :track, slug: 'elixir'

    concept_1 = create :concept, track: track_1
    concept_2 = create :concept, track: track_2
    concept_3 = create :concept, track: track_2
    concept_4 = create :concept, track: track_3

    Git::SyncConceptAuthors.expects(:call).with(concept_1)
    Git::SyncConceptAuthors.expects(:call).with(concept_2)
    Git::SyncConceptAuthors.expects(:call).with(concept_3)
    Git::SyncConceptAuthors.expects(:call).with(concept_4)

    Git::SyncAuthorsAndContributors.()
  end

  test "sync contributors of all concepts" do
    track_1 = create :track, slug: 'ruby'
    track_2 = create :track, slug: 'csharp'
    track_3 = create :track, slug: 'elixir'

    concept_1 = create :concept, track: track_1
    concept_2 = create :concept, track: track_2
    concept_3 = create :concept, track: track_2
    concept_4 = create :concept, track: track_3

    Git::SyncConceptContributors.expects(:call).with(concept_1)
    Git::SyncConceptContributors.expects(:call).with(concept_2)
    Git::SyncConceptContributors.expects(:call).with(concept_3)
    Git::SyncConceptContributors.expects(:call).with(concept_4)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing authors of other concepts when an error occurs" do
    track_1 = create :track, slug: 'ruby'
    track_2 = create :track, slug: 'csharp'
    track_3 = create :track, slug: 'elixir'

    concept_1 = create :concept, track: track_1
    concept_2 = create :concept, track: track_2
    concept_3 = create :concept, track: track_2
    concept_4 = create :concept, track: track_3

    Git::SyncConceptAuthors.expects(:call).with(concept_1).raises(RuntimeError)
    Git::SyncConceptAuthors.expects(:call).with(concept_2)
    Git::SyncConceptAuthors.expects(:call).with(concept_3)
    Git::SyncConceptAuthors.expects(:call).with(concept_4)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing contributors of other concepts when an error occurs" do
    track_1 = create :track, slug: 'ruby'
    track_2 = create :track, slug: 'csharp'
    track_3 = create :track, slug: 'elixir'

    concept_1 = create :concept, track: track_1
    concept_2 = create :concept, track: track_2
    concept_3 = create :concept, track: track_2
    concept_4 = create :concept, track: track_3

    Git::SyncConceptContributors.expects(:call).with(concept_1)
    Git::SyncConceptContributors.expects(:call).with(concept_2).raises(RuntimeError)
    Git::SyncConceptContributors.expects(:call).with(concept_3)
    Git::SyncConceptContributors.expects(:call).with(concept_4)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing contributors of concept when authors syncing errors" do
    concept = create :concept

    Git::SyncConceptAuthors.expects(:call).with(concept).raises(RuntimeError)
    Git::SyncConceptContributors.expects(:call).with(concept)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing authors of concept when contributors syncing errors" do
    concept = create :concept

    Git::SyncConceptAuthors.expects(:call).with(concept)
    Git::SyncConceptContributors.expects(:call).with(concept).raises(RuntimeError)

    Git::SyncAuthorsAndContributors.()
  end
end
