require "test_helper"

class SPI::SolutionImageDataControllerTest < ActionDispatch::IntegrationTest
  test "returns the data needed to draw the image" do
    track = create :track, slug: 'ruby', title: 'Ruby'
    exercise = create :practice_exercise, track:, slug: 'bob', title: 'Bob'
    user = create :user, handle: 'ihid'
    solution = create(:practice_solution, exercise:, user:)
    submission = create(:submission, solution:)
    iteration = create(:iteration, solution:, submission:)
    create(:submission_file, submission:, filename: 'bob.rb', content: 'def hey; end')
    solution.update(published_iteration: iteration, published_at: Time.current)

    get "/spi/solution_image_data/ruby/bob/ihid"

    assert_response :ok
    actual = JSON.parse(response.body, symbolize_names: true)
    assert_equal [{ filename: 'bob.rb', content: 'def hey; end' }], actual[:code][:files]
    assert_equal 'ihid', actual[:footer][:handle]
    assert_equal 'Bob', actual[:footer][:exercise_title]
    assert_equal 'Ruby', actual[:footer][:track_title]
    # Without this the generator has no way to colour the code - it can't load
    # the stylesheet that normally does it.
    assert actual[:highlight_theme][:keyword][:colour].present?
  end

  test "is reachable without authentication" do
    # The generator calls this over the internal ALB with no session.
    solution = create :practice_solution

    get "/spi/solution_image_data/#{solution.track.slug}/#{solution.exercise.slug}/#{solution.user.handle}"

    assert_response :ok
  end

  test "404s for a solution that doesn't exist" do
    get "/spi/solution_image_data/nope/nope/nope"

    assert_response :not_found
  end
end
