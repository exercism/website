class Settings::GithubSyncerController < ApplicationController
  skip_before_action :verify_authenticity_token, only: %i[update sync_everything sync_track sync_solution sync_iteration destroy]

  def show
    @just_connected = !!params[:connected]
  end

  def update
    permitted = current_user.insider? ?
      %w[
        processing_method
        main_branch_name
        path_template
        commit_message_template
        enabled
        sync_exercise_files
        sync_on_iteration_creation
      ] :
      %w[
        enabled
      ]
    syncer = current_user.github_solution_syncer
    updated = Exercism.without_bullet do
      syncer.update(params.require(:github_solution_syncer).permit(permitted))
    end
    return if updated

    render json: {
      error: {
        type: :invalid_github_solution_syncer,
        message: update_error_message(syncer)
      }
    }, status: :bad_request
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
    solution = Solution.for!(current_user.handle, params[:track_slug], params[:exercise_slug])
    User::GithubSolutionSyncer::SyncSolution.defer(solution)
  rescue ActiveRecord::RecordNotFound
    render json: {
      error: "We couldn't find data about you solving this exercise"
    }, status: :not_found
  end

  def sync_iteration
    solution = Solution.for!(current_user.handle, params[:track_slug], params[:exercise_slug])
    iteration = solution.iterations.find_by!(idx: params[:iteration_idx])
    User::GithubSolutionSyncer::SyncIteration.defer(iteration)
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
      redirect_to settings_github_syncer_path(connected: true), alert: e.message
    end
  end

  def destroy
    current_user.github_solution_syncer&.destroy
  end

  private
  def update_error_message(syncer)
    if syncer.errors.of_kind?(:main_branch_name, :invalid)
      return t(".invalid_main_branch_name", max_length: User::GithubSolutionSyncer::MAX_BRANCH_NAME_LENGTH)
    end

    t(".failed")
  end
end
