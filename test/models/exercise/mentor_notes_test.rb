require "test_helper"

class Exercise::MentorNotesTest < ActiveSupport::TestCase
  test "#edit_url returns edit url if mentoring notes is present" do
    track = create :track
    exercise = create :concept_exercise, track: track
    repo = mock
    repo.expects(:mentor_notes_for).with(track.slug, exercise.slug).returns("mentor notes")
    notes = Exercise::MentorNotes.new(exercise, copy_repo: repo)

    assert_equal(
      "https://github.com/exercism/website-copy/edit/main/tracks/ruby/exercises/strings/mentoring.md",
      notes.edit_url
    )
  end

  test "#edit_url returns new url if mentoring notes is blank" do
    track = create :track
    exercise = create :concept_exercise, track: track
    repo = mock
    repo.expects(:mentor_notes_for).with(track.slug, exercise.slug).returns("")
    notes = Exercise::MentorNotes.new(exercise, copy_repo: repo)

    assert_equal(
      "https://github.com/exercism/website-copy/new/main/tracks/ruby/exercises/strings?filename=strings/mentoring.md",
      notes.edit_url
    )
  end
end
