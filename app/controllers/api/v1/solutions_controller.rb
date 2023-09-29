class API::V1::SolutionsController < API::BaseController
  def show
    begin
      solution = Solution.find_by!(uuid: params[:id])
    rescue ActiveRecord::RecordNotFound
      return render_solution_not_found
    end

    return render_solution_not_accessible unless solution.viewable_by?(current_user)

    if solution.user == current_user
      respond_with_authored_solution(solution)
    else
      respond_with_solution(solution)
    end
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
      user_track = UserTrack.find_by!(user: current_user, track:)
    rescue ActiveRecord::RecordNotFound
      return render_403(:track_not_joined)
    end

    begin
      solution = current_user.solutions.find_by!(exercise_id: exercise.id)
    rescue ActiveRecord::RecordNotFound
      return render_403(:solution_not_unlocked) unless user_track.exercise_unlocked?(exercise)

      solution = Solution::Create.(current_user, exercise)
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
  def respond_with_authored_solution(solution)
    Solution::UpdateToLatestExerciseVersion.(solution) unless solution.downloaded?

    respond_with_solution(solution)

    # Only set this if we've not 500'd
    solution.update(downloaded_at: Time.current)
  end

  def respond_with_solution(solution)
    render json: SerializeSolutionForCLI.(solution, current_user)
  end
end
