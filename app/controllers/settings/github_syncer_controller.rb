class Settings::GithubSyncerController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[update sync_everything sync_track sync_solution sync_iteration]

  def show
    current_user.github_solution_syncer
  end

  def update
    current_user.github_solution_syncer.update!(
      params.require(:github_solution_syncer).permit(
        %w[
          processing_method
          main_branch_name
          path_template
          commit_message_template
          enabled
          sync_exercise_files
          sync_on_iteration_creation
        ]
      )
    )
  end

  def sync_everything
    User::GithubSolutionSyncer::SyncEverything.defer(current_user)
  end

  def sync_track
    user_track = UserTrack.for!(current_user, params[:track_slug])
    User::GithubSolutionSyncer::SyncTrack.defer(user_track)
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "We couldn't find data about you solving exercises on this track"
    }, status: :not_found
  end

  def sync_solution
    solution = Solution.for!(user, params[:track_slug], params[:exercise_slug])
    User::GithubSyncer::SyncSolution.defer(solution)
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "We couldn't find data about you solving this exercise"
    }, status: :not_found
  end

  def sync_iteration
    solution = Solution.for!(user, params[:track_slug], params[:exercise_slug])
    iteration = solution.iterations.find_by!(idx: params[:iteration_idx])
    User::GithubSyncer::SyncIteration.defer(iteration)
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "We couldn't find data about this iteration"
    }, status: :not_found
  end

  def callback
    installation_id = params[:installation_id]

    if installation_id.blank?
      redirect_to settings_github_syncer_path, alert: "Missing installation ID"
      return
    end

    begin
      User::GithubSolutionSyncer::Create.(current_user, installation_id)
      redirect_to settings_github_syncer_path, notice: "GitHub connected successfully"
    rescue GithubSolutionSyncerCreationError => e
      redirect_to settings_github_syncer_path, alert: e.message
    end
  end

  def destroy
    current_user.github_solution_syncer&.destroy
    redirect_to settings_github_syncer_path, notice: "GitHub disconnected"
  end
end
