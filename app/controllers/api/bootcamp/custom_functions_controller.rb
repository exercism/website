class API::Bootcamp::CustomFunctionsController < API::Bootcamp::BaseController
  def index
    @custom_functions = current_user.bootcamp_custom_functions
    @custom_functions = @custom_functions.active if params[:filter] == "active"

    render json: {
      custom_functions: @custom_functions.map { |cf| SerializeBootcampCustomFunctionSummary.(cf) }
    }
  end

  def for_interpreter
    @custom_functions = current_user.bootcamp_custom_functions.where(uuid: params[:uuids].split(','))

    render json: {
      custom_functions: @custom_functions.map do |cf|
        {
          fn_name: cf.fn_name,
          fn_arity: cf.fn_arity,
          code: cf.code
        }
      end
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
      :fn_name,
      :fn_arity,
      :depends_on
    )
    @custom_function.update(data)

    render json: {}, status: :ok
  end
end
