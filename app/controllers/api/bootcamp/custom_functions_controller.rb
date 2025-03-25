class API::Bootcamp::CustomFunctionsController < API::Bootcamp::BaseController
  def index
    @custom_functions = current_user.bootcamp_custom_functions.order('name')
    @custom_functions = @custom_functions.active if params[:filter] == "active"

    render json: {
      custom_functions: @custom_functions.map { |cf| SerializeBootcampCustomFunctionSummary.(cf) }
    }
  end

  def update
    @custom_function = current_user.bootcamp_custom_functions.find_by!(uuid: params[:uuid])
    data = params[:custom_function].slice(
      :name,
      :active,
      :description,
      :code,
      :tests,
      :arity,
      :depends_on
    )
    @custom_function.update(data)

    render json: {}, status: :ok
  end

  def destroy
    @custom_function = current_user.bootcamp_custom_functions.find_by!(uuid: params[:uuid])
    @custom_function.destroy

    render json: {}, status: :ok
  end
end
