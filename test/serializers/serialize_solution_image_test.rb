require 'test_helper'

class SerializeSolutionImageTest < ActiveSupport::TestCase
  test "serializes everything needed to draw the image" do
    track = create :track, slug: 'ruby', title: 'Ruby'
    exercise = create :practice_exercise, track:, title: 'Bob'
    user = create :user, handle: 'ihid'
    solution = create(:practice_solution, exercise:, user:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, solution:, submission:)
    create(:submission_file, submission:, filename: 'bob.rb', content: 'def hey; end')
    solution.update(published_iteration: iteration, published_at: Time.current)

    actual = SerializeSolutionImage.(solution)

    assert_equal track.highlightjs_language, actual[:code][:language]
    assert_equal track.indent_size, actual[:code][:indent_size]
    assert_equal [{ filename: 'bob.rb', content: 'def hey; end' }], actual[:code][:files]
    assert_equal 'ihid', actual[:footer][:handle]
    assert_equal 'Bob', actual[:footer][:exercise_title]
    assert_equal 'Ruby', actual[:footer][:track_title]
    assert_equal user.avatar_url, actual[:footer][:avatar_url]
  end

  test "includes the theme so the generator can colour code without a stylesheet" do
    solution = create :practice_solution

    actual = SerializeSolutionImage.(solution)

    assert_equal SerializeHighlightjsTheme.(), actual[:highlight_theme]
  end

  test "returns no files when nothing is published" do
    solution = create :practice_solution

    actual = SerializeSolutionImage.(solution)

    assert_empty actual[:code][:files]
  end
end
