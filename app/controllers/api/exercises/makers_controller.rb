module API
  module Exercises
    class MakersController < BaseController
      skip_before_action :authenticate_user!
      before_action :authenticate_user
      before_action :use_exercise

      def index
        mapper = proc do |user|
          {
            avatar_url: user.avatar_url,
            handle: user.handle,
            reputation: user.formatted_reputation,
            links: {
              self: user.profile ? profile_url(user) : user
            }
          }
        end

        render json: {
          authors: @exercise.authors.includes(:profile).map { |author| mapper.(author) },
          contributors: @exercise.contributors.includes(:profile).map { |contributor| mapper.(contributor) },
          links: {
            github: "https://github.com/exercism/#{@track.slug}/commits/main/exercises/#{@exercise.git_type}/#{@exercise.slug}" # rubocop:disable Layout/LineLength
          }
        }
      end

      private
      def use_exercise
        @track = Track.find(params[:track_id])
        @exercise = @track.exercises.find(params[:exercise_id])
      end
    end
  end
end
