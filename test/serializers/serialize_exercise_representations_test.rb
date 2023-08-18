require 'test_helper'

class SerializeExerciseRepresentationsTest < ActiveSupport::TestCase
  test "serialize representations" do
    current_time = Time.zone.now
    author = create :user
    editor = create :user
    track_1 = create :track, slug: 'ruby', title: 'Ruby'
    track_2 = create :track, slug: 'csharp', title: 'C#'
    exercise_1 = create :practice_exercise, slug: 'bob', title: 'Bob', icon_name: 'bob', track: track_1
    exercise_2 = create :practice_exercise, slug: 'leap', title: 'Leap', icon_name: 'leap', track: track_2
    representation_1 = create :exercise_representation, id: 3, feedback_markdown: 'Yay', exercise: exercise_1, num_submissions: 5,
      last_submitted_at: current_time - 5.days, feedback_added_at: current_time - 4.days,
      feedback_author_id: author.id, feedback_editor_id: editor.id
    representation_2 = create :exercise_representation, id: 7, feedback_markdown: 'Jip', exercise: exercise_2, num_submissions: 3,
      last_submitted_at: current_time - 2.days, feedback_added_at: current_time - 1.day,
      feedback_author_id: author.id, feedback_editor_id: editor.id

    expected = [
      {
        id: 3,
        exercise: {
          icon_url: 'https://assets.exercism.org/exercises/bob.svg',
          title: 'Bob'
        },
        track: {
          icon_url: 'https://assets.exercism.org/tracks/ruby.svg',
          title: 'Ruby'
        },
        num_submissions: 5,
        appears_frequently: true,
        feedback_author: { handle: author.handle },
        feedback_editor: { handle: editor.handle },
        feedback_added_at: current_time - 4.days,
        feedback_html: "<p>Yay</p>\n",
        last_submitted_at: current_time - 5.days,
        links: {
          edit: "/mentoring/automation/#{representation_1.uuid}/edit"
        }
      },
      {
        id: 7,
        exercise: {
          icon_url: 'https://assets.exercism.org/exercises/leap.svg',
          title: 'Leap'
        },
        track: {
          icon_url: 'https://assets.exercism.org/tracks/csharp.svg',
          title: 'C#'
        },
        num_submissions: 3,
        appears_frequently: false,
        feedback_author: { handle: author.handle },
        feedback_editor: { handle: editor.handle },
        feedback_added_at: current_time - 1.day,
        feedback_html: "<p>Jip</p>\n",
        last_submitted_at: current_time - 2.days,
        links: {
          edit: "/mentoring/automation/#{representation_2.uuid}/edit"
        }
      }
    ]

    assert_equal expected, SerializeExerciseRepresentations.([representation_1, representation_2], params: {})
  end

  test "edit links uses params" do
    author = create :user
    editor = create :user
    current_time = Time.zone.now
    track = create :track, slug: 'ruby', title: 'Ruby'
    exercise = create(:practice_exercise, slug: 'bob', title: 'Bob', icon_name: 'bob', track:)
    representation = create :exercise_representation, id: 3, feedback_markdown: 'Yay', exercise:, num_submissions: 5,
      last_submitted_at: current_time - 5.days, feedback_added_at: current_time - 4.days,
      feedback_author_id: author.id, feedback_editor_id: editor.id

    expected = [
      {
        id: 3,
        exercise: {
          icon_url: 'https://assets.exercism.org/exercises/bob.svg',
          title: 'Bob'
        },
        track: {
          icon_url: 'https://assets.exercism.org/tracks/ruby.svg',
          title: 'Ruby'
        },
        num_submissions: 5,
        appears_frequently: true,
        feedback_author: { handle: author.handle },
        feedback_editor: { handle: editor.handle },
        feedback_added_at: current_time - 4.days,
        feedback_html: "<p>Yay</p>\n",
        last_submitted_at: current_time - 5.days,
        links: {
          edit: "/mentoring/automation/#{representation.uuid}/edit?source%5Bpage%5D=5&source%5Btrack_slug%5D=ruby"
        }
      }
    ]

    params = { track_slug: 'ruby', page: 5 }
    assert_equal expected, SerializeExerciseRepresentations.([representation], params:)
  end

  test "n+1s handled correctly" do
    create_np1_data

    Bullet.profile do
      SerializeExerciseRepresentations.(Exercise::Representation.all, params: {})
    end
  end
end
