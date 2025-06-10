class SPI::Bootcamp::Solutions::ChatMessagesController < SPI::BaseController
  def create
    Bootcamp::ChatMessage::Create.(
      Bootcamp::Solution.find(params[:solution_id]),
      params[:content],
      :llm
    )

    head :ok
  end
end
