class API::Bootcamp::DrawingsController < API::Bootcamp::BaseController
  before_action :use_drawing

  def update
    @drawing.update(code: params[:code]) if params[:code].present?
    @drawing.update(title: params[:title]) if params[:title].present?
    @drawing.update(background_slug: params[:background_slug]) if params[:background_slug].present?

    render json: {}, status: :ok
  end

  private
  def use_drawing
    @drawing = current_user.bootcamp_drawings.find_by!(uuid: params[:uuid])
  end
end
