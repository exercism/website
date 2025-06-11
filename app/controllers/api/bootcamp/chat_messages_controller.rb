class API::Bootcamp::ChatMessagesController < API::BaseController
  def create
    solution = current_user.bootcamp_solutions.find_by!(uuid: params[:solution_uuid])

    Bootcamp::ChatMessage::Create.(
      solution,
      params[:content],
      :user
    )

    Bootcamp::ChatMessage::TriggerLLM.(solution, params[:code])

    head :accepted
  end
end
