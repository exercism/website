module API
  class SolutionsController < BaseController
    def show
      begin
        solution = current_user.solutions.find_by!(uuid: params[:id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless current_user.may_view_solution?(solution)

      respond_with_authored_solution(solution)
    end

    def latest
      return render_404(:track_not_found, fallback_url: tracks_url) if params[:track_id].blank?

      begin
        track = Track.find_by!(slug: params[:track_id])
      rescue ActiveRecord::RecordNotFound
        return render_404(:track_not_found, fallback_url: tracks_url)
      end

      begin
        exercise = track.exercises.find_by!(slug: params[:exercise_id])
      rescue ActiveRecord::RecordNotFound
        return render_404(:exercise_not_found, fallback_url: track_url(track))
      end

      begin
        user_track = UserTrack.find_by!(user: current_user, track: track)
      rescue ActiveRecord::RecordNotFound
        return render_403(:track_not_joined)
      end

      begin
        solution = current_user.solutions.find_by!(exercise_id: exercise.id)
      rescue ActiveRecord::RecordNotFound
        return render_403(:solution_not_unlocked) unless user_track.exercise_available?(exercise)

        solution = Solution::Create.(user_track, exercise)
      end

      respond_with_authored_solution(solution)
    end

    def update
      begin
        solution = Solution.find_by!(uuid: params[:id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      begin
        files = CLI::PrepareUploadedFiles.(params[:files])
      rescue IterationFileTooLargeError
        return render_error(400, :file_too_large, "#{file.original_filename} is too large")
      end

      begin
        Iteration::Create.(solution, files, :cli)
      rescue DuplicateIterationError
        return render_error(400, :duplicate_iteration)
      end

      render json: {}, status: :created
    end

    private
    def set_track
      @track = Track.find_by!(slug: params[:track_id])
    end

    def set_exercise
      @exercise = @track.exercises.find_by!(slug: params[:exercise_id])
    end

    def respond_with_authored_solution(solution)
      unless solution.downloaded?
        solution.update(
          git_slug: solution.exercise.slug,
          git_sha: solution.track_head
        )
      end

      responder = API::SolutionSerializer.new(solution, current_user)
      render json: responder.to_hash

      # Only set this if we've not 500'd
      solution.update(downloaded_at: Time.current)
    end
  end
end
