class API::Bootcamp::ChatMessagesController < API::BaseController
  def create
    solution = current_user.bootcamp_solutions.find_by!(uuid: params[:solution_uuid])

    message = Bootcamp::ChatMessage::Create.(
      solution,
      params[:content],
      :user
    )

    Bootcamp::ChatMessage::TriggerLLM.(message)

    head :accepted
  end
end
