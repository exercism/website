module ReactComponents
  module CommunitySolutions
    class StarButton < ReactComponent
      initialize_with :solution

      def to_s
        super("community-solutions-star-button", {
          num_stars: solution.num_stars,
          is_starred: solution.starred_by?(current_user),
          user_signed_in: current_user.present?,
          links: {
            star: Exercism::Routes.api_track_exercise_community_solution_star_url(
              solution.track,
              solution.exercise,
              solution.user.handle
            )
          }
        })
      end
    end
  end
end
