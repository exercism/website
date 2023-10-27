require 'test_helper'

class SerializeCommunitySolutionTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create(:iteration, solution:)
    expected = {
      uuid: solution.uuid,
      snippet: solution.snippet,
      num_views: solution.num_views,
      num_stars: solution.num_stars,
      num_comments: solution.num_comments,
      representation_num_published_solutions: solution.published_exercise_representation&.num_published_solutions,
      num_iterations: solution.num_iterations,
      num_loc: nil,
      iteration_status: iteration.status.to_s.to_sym,
      published_iteration_head_tests_status: solution.published_iteration_head_tests_status.to_s.to_sym,
      published_at: solution.published_at,
      is_out_of_date: solution.out_of_date?,
      language: solution.track.highlightjs_language,
      author: {
        handle: solution.user.handle,
        flair: solution.user.flair,
        avatar_url: solution.user.avatar_url
      },
      exercise: {
        title: solution.exercise.title,
        icon_url: solution.exercise.icon_url
      },
      track: {
        title: solution.track.title,
        icon_url: solution.track.icon_url,
        highlightjs_language: solution.track.highlightjs_language
      },
      links: {
        public_url: Exercism::Routes.published_solution_url(solution),
        private_iterations_url: Exercism::Routes.track_exercise_iterations_url(solution.track, solution.exercise)
      }
    }

    assert_equal expected, SerializeCommunitySolution.(solution)
  end

  test "num_loc works" do
    solution = create :practice_solution, num_loc: 10
    output = SerializeCommunitySolution.(solution)
    assert_equal 10, output[:num_loc]
  end
end
