# This controller listens for Github workflow_run webhook events,
# for which the "Workflow runs" event type must be enabled in GitHub.
# See https://docs.github.com/en/developers/webhooks-and-events/webhook-events-and-payloads#workflow_run
class Webhooks::WorkflowRunUpdatesController < Webhooks::GithubBaseController
  def create
    head :no_content
  end
end
