class SPI::Bootcamp::ChatMessagesController < SPI::BaseController
  def create
    Bootcamp::ChatMessage::Create.(
      Bootcamp::Solution.find_by!(uuid: params[:solution_uuid]),
      params[:content],
      :llm
    )

    head :ok
  end
end
