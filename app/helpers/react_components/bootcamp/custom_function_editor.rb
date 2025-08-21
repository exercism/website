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
        custom_functions:,
        links: {
          custom_fns_dashboard: Exercism::Routes.bootcamp_custom_functions_url,
          update_custom_fns: Exercism::Routes.api_bootcamp_custom_function_url(custom_function)
        }
      }
    end

    private
    def custom_functions
      ::Bootcamp::CustomFunction::BuildRecursiveList.(current_user, custom_function&.depends_on || [])
    end
  end
end
