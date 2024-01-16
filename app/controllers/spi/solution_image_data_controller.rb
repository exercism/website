module SPI
  class SolutionImageDataController < BaseController
    def show
      solution = Solution.for!(
        params[:user_handle],
        params[:track_slug],
        params[:exercise_slug]
      )

      exercise = solution.exercise
      track = exercise.track
      file = solution.latest_published_iteration_submission.files.first
      snippet = solution.snippet.presence || file.content[0, 10]
      render json: {
        solution: {
          snippet:,
          extension: File.extname(file.filename),
          language: track.highlightjs_language,
          track_icon_url: track.icon_url,
          exercise_icon_url: exercise.icon_url,
          user_avatar_url: solution.user.avatar_url
        }
      }
    end
  end
end
