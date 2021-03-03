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

    Git::SyncAuthors.expects(:call).with(exercise_1)
    Git::SyncAuthors.expects(:call).with(exercise_2)
    Git::SyncAuthors.expects(:call).with(exercise_3)
    Git::SyncAuthors.expects(:call).with(exercise_4)

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

    Git::SyncContributors.expects(:call).with(exercise_1)
    Git::SyncContributors.expects(:call).with(exercise_2)
    Git::SyncContributors.expects(:call).with(exercise_3)
    Git::SyncContributors.expects(:call).with(exercise_4)

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

    Git::SyncAuthors.expects(:call).with(exercise_1).raises(RuntimeError)
    Git::SyncAuthors.expects(:call).with(exercise_2)
    Git::SyncAuthors.expects(:call).with(exercise_3)
    Git::SyncAuthors.expects(:call).with(exercise_4)

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

    Git::SyncContributors.expects(:call).with(exercise_1)
    Git::SyncContributors.expects(:call).with(exercise_2).raises(RuntimeError)
    Git::SyncContributors.expects(:call).with(exercise_3)
    Git::SyncContributors.expects(:call).with(exercise_4)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing contributors of exercise when authors syncing errors" do
    exercise = create :concept_exercise

    Git::SyncAuthors.expects(:call).with(exercise).raises(RuntimeError)
    Git::SyncContributors.expects(:call).with(exercise)

    Git::SyncAuthorsAndContributors.()
  end

  test "continues syncing authors of exercise when contributors syncing errors" do
    exercise = create :concept_exercise

    Git::SyncAuthors.expects(:call).with(exercise)
    Git::SyncContributors.expects(:call).with(exercise).raises(RuntimeError)

    Git::SyncAuthorsAndContributors.()
  end
end
