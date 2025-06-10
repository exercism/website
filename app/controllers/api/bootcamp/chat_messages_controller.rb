class API::Bootcamp::ChatMessagesController < API::BaseController
  def create
    solution = current_user.bootcamp_solutions.find(params[:solution_id])

    message = Bootcamp::ChatMessage::Create.(
      solution,
      params[:content],
      :user
    )

    Bootcamp::ChatMessage::TriggerLlm.(message)

    head :accepted
  end
end
