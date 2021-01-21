module API
  class SolutionsController < BaseController
    def index
      solutions = Solution::Search.(
        current_user,
        criteria: params[:criteria],
        status: params[:status],
        mentoring_status: params[:mentoring_status],
        page: params[:page],
        per: params[:per],
        sort: params[:sort]
      )

      render json: SerializeSolutionsForStudent.(solutions)
    end

    def complete
      begin
        solution = Solution.find_by!(uuid: params[:id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      user_track = UserTrack.for(current_user, solution.track)
      return render_404(:track_not_joined) unless user_track

      changes = UserTrack::MonitorChanges.(user_track) do
        Solution::Complete.(solution, user_track)
      end

      output = {
        unlocked_exercises: changes[:unlocked_exercises].map do |exercise|
          {
            slug: exercise.slug,
            title: exercise.title,
            icon_name: exercise.icon_name
          }
        end,
        unlocked_concepts: changes[:unlocked_concepts].map do |concept|
          {
            slug: concept.slug,
            name: concept.name
          }
        end,
        concept_progressions: changes[:concept_progressions].map do |data|
          {
            slug: data[:concept].slug,
            name: data[:concept].name,
            from: data[:from],
            to: data[:to],
            total: data[:total]
          }
        end
      }
      render json: output, status: :ok
    end

    ##############
    # CLI Method #
    ##############
    def show
      begin
        solution = current_user.solutions.find_by!(uuid: params[:id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless current_user.may_view_solution?(solution)

      respond_with_authored_solution(solution)
    end

    ##############
    # CLI Method #
    ##############
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

        solution = Solution::Create.(current_user, exercise)
      end

      respond_with_authored_solution(solution)
    end

    ##############
    # CLI Method #
    ##############
    # This is a private CLI-only method. The "normal" path should
    # be through POST /submissions and # POST /iterations
    def update
      begin
        solution = Solution.find_by!(uuid: params[:id])
      rescue ActiveRecord::RecordNotFound
        return render_solution_not_found
      end

      return render_solution_not_accessible unless solution.user_id == current_user.id

      begin
        files = Submission::PrepareHttpFiles.(params[:files])
      rescue SubmissionFileTooLargeError
        return render_error(400, :file_too_large, "#{file.original_filename} is too large")
      end

      begin
        submission = Submission::Create.(solution, files, :cli)
        Iteration::Create.(solution, submission)
      rescue DuplicateSubmissionError
        return render_error(400, :duplicate_submission)
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
      solution.update_git_info! unless solution.downloaded?

      render json: SerializeSolutionForCLI.(solution, current_user)

      # Only set this if we've not 500'd
      solution.update(downloaded_at: Time.current)
    end
  end
end
