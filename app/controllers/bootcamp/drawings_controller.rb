class Bootcamp::DrawingsController < Bootcamp::BaseController
  def create
    @drawing = current_user.bootcamp_drawings.create!
    redirect_to edit_bootcamp_drawing_path(@drawing)
  end

  def edit
    @drawing = current_user.bootcamp_drawings.find_by!(uuid: params[:uuid])
  end
end
