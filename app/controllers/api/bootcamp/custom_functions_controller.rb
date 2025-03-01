class API::Bootcamp::CustomFunctionsController < API::Bootcamp::BaseController
  def index
    @custom_functions = current_user.bootcamp_custom_functions
    @custom_functions = @custom_functions.active if params[:filter] == "active"

    render json: {
      custom_functions: @custom_functions.map { |cf| SerializeBootcampCustomFunctionSummary.(cf) }
    }
  end

  def for_interpreter
    @custom_functions = current_user.bootcamp_custom_functions.where(name: params[:name].split(','))

    render json: {
      custom_functions: @custom_functions.map do |cf|
        {
          name: cf.name,
          arity: cf.arity,
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
      :arity,
      :depends_on
    )
    @custom_function.update(data)

    render json: {}, status: :ok
  end
end
