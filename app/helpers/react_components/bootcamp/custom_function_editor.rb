module ReactComponents
  class Bootcamp::CustomFunctionEditor < ReactComponent
    initialize_with :custom_function

    def to_s
      super(id, data)
    end

    def id = "bootcamp-custom-function-editor"

    def data
      {
        custom_function: SerializeBootcampCustomFunction.(custom_function),
        available_custom_functions:,
        depends_on:,
        links: {
          custom_fns_dashboard: Exercism::Routes.bootcamp_custom_functions_url,
          update_custom_fns: Exercism::Routes.api_bootcamp_custom_function_url(custom_function),
          get_custom_fns: Exercism::Routes.api_bootcamp_custom_functions_url,
          get_custom_fns_for_interpreter: Exercism::Routes.for_interpreter_api_bootcamp_custom_functions_url
        }
      }
    end

    private
    def available_custom_functions
      current_user.bootcamp_custom_functions.active.order(:name).map do |custom_function|
        SerializeBootcampCustomFunctionSummary.(custom_function)
      end
    end

    def depends_on
      ::Bootcamp::CustomFunction::BuildRecursiveList.(current_user, custom_function.depends_on)
    end
  end
end
