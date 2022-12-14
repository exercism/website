# This controller listens for Github workflow_run webhook events,
# for which the "Workflow runs" event type must be enabled in GitHub.
# See https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#workflow_run
class Webhooks::WorkflowRunUpdatesController < Webhooks::GithubBaseController
  def create
    ::Webhooks::ProcessWorkflowRunUpdate.(
      # params[:action] does not work as it is populated by Rails with the action method name
      action: request.request_parameters[:action],
      repo: params.dig(:repository, :full_name),
      head_branch: params.dig(:workflow_run, :head_branch),
      path: params.dig(:workflow_run, :path),
      conclusion: params.dig(:workflow_run, :conclusion),
      referenced_workflows: params.dig(:workflow_run, :referenced_workflows).to_a.map { |workflow| workflow[:path] }
    )

    head :no_content
  end
end
