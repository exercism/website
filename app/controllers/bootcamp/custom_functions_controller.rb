class Bootcamp::CustomFunctionsController < ApplicationController
  def index
    @custom_functions = current_user.bootcamp_custom_functions
  end

  def create
    @custom_functions = current_user.bootcamp_custom_functions.create!
    redirect_to edit_bootcamp_drawing_path(@drawing)
  end

  def edit
    @custom_function = current_user.bootcamp_custom_functions.find_by!(uuid: params[:uuid])
  end
end
