class Bootcamp::CustomFunctionsController < Bootcamp::BaseController
  def index
    @custom_functions = current_user.bootcamp_custom_functions.order(:name)
  end

  def create
    @custom_function = current_user.bootcamp_custom_functions.create!
    redirect_to edit_bootcamp_custom_function_path(@custom_function.short_name)
  end

  def edit
    @custom_function = current_user.bootcamp_custom_functions.find_by!(name: "my##{params[:short_name]}")
  rescue StandardError
    @custom_function = Bootcamp::CustomFunction::CreatePredefinedForUser.(current_user, params[:short_name])
    raise ActiveRecord::RecordNotFound unless @custom_function
  end
end
