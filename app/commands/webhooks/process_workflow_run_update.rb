class Webhooks::ProcessWorkflowRunUpdate
  include Mandate

  initialize_with params: Mandate::KWARGS

  def call
    return unless params[:action] == 'completed'
    return unless params[:conclusion] == 'success'
  end
end
