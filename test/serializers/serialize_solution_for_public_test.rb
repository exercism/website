require 'test_helper'

class SerializeSolutionForPublicTest < ActiveSupport::TestCase
  test "basic to_hash" do
    solution = create :practice_solution
    create :user_track, user: solution.user, track: solution.track
    expected = {
      solution: {
        id: solution.uuid,
        url: "https://test.exercism.io/tracks/ruby/exercises/bob/solutions/#{solution.user.handle}",
        num_views: 1270, # TODO
        num_stars: 10, # TODO
        num_comments: 2, # TODO
        num_iterations: 3, # TODO
        num_locs: "9 - 18", # TODO
        published_at: solution.published_at,
        user: {
          handle: solution.user.handle,
          avatar_url: solution.user.avatar_url
        },
        exercise: {
          title: solution.exercise.title,
          icon_name: solution.exercise.icon_name
        },
        track: {
          title: solution.track.title,
          icon_name: solution.track.icon_name
        }
      }
    }

    assert_equal expected, SerializeSolutionForPublic.(solution)
  end
end
