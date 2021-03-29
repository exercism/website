require 'test_helper'

class SerializeCommunitySolutionTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    expected = {
      solution: {
        id: solution.uuid,
        url: "https://test.exercism.io/tracks/ruby/exercises/bob/solutions/#{solution.user.handle}",
        num_views: solution.num_views,
        num_stars: solution.num_stars,
        num_comments: solution.num_comments,
        num_iterations: solution.num_iterations,
        num_loc: solution.num_loc,
        published_at: solution.published_at,
        user: {
          handle: solution.user.handle,
          avatar_url: solution.user.avatar_url
        },
        exercise: {
          title: solution.exercise.title,
          icon_url: solution.exercise.icon_url
        },
        track: {
          title: solution.track.title,
          icon_url: solution.track.icon_url
        }
      }
    }

    assert_equal expected, SerializeCommunitySolution.(solution)
  end
end
