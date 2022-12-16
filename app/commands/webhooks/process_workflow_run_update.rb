class Webhooks::ProcessWorkflowRunUpdate
  include Mandate

  initialize_with params: Mandate::KWARGS

  def call
    Tooling::Representer::HandleDeploy.defer(track) if handle_representer_deploy?
  end

  private
  def handle_representer_deploy?
    params[:action] == 'completed' &&
      params[:conclusion] == 'success' &&
      params[:head_branch] == 'main' &&
      params[:path] == '.github/workflows/deploy.yml' &&
      params[:repo].ends_with?('-representer') &&
      params[:referenced_workflows].include?('exercism/github-actions/.github/workflows/docker-build-push-image.yml@main') &&
      track
  end

  memoize
  def track = Track.for_repo(params[:repo])
end
