class Settings::GithubSyncerController < ApplicationController
  def show
    current_user.github_solution_syncer
  end

  def update
    user.github_solution_syncer.update!(
      params.require(:github_solution_syncer).permit(
        %w[
          processing_method
          main_branch_name
          path_template
          commit_message_template
          active
          sync_on_iteration_creation
        ]
      )
    )
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
