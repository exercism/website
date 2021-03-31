require 'test_helper'

class SerializeCommunitySolutionTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    iteration = create :iteration, solution: solution
    expected = {
      id: solution.uuid,
      snippet: solution.snippet,
      num_views: solution.num_views,
      num_stars: solution.num_stars,
      num_comments: solution.num_comments,
      num_iterations: solution.num_iterations,
      num_loc: solution.num_loc,
      iteration_status: iteration.status.to_s,
      published_at: solution.published_at,
      is_out_of_date: solution.out_of_date?,
      language: solution.track.highlightjs_language,
      author: {
        handle: solution.user.handle,
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
        private_url: Exercism::Routes.private_solution_url(solution)
      }
    }

    assert_equal expected, SerializeCommunitySolution.(solution)
  end
end
