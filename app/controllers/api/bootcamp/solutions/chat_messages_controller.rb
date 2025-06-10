class API::Bootcamp::Solutions::ChatMessagesController < API::BaseController
  def create
    solution = current_user.bootcamp_solutions.find(params[:solution_id])

    message = Bootcamp::Solution::ChatMessage.(
      solution,
      params[:content],
      :user
    )

    Bootcamp::Solution::ChatMessage::Trigger.(message)

    head :accepted
  end
end
