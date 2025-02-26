module ReactComponents
  class Bootcamp::CustomFunctionEditor < ReactComponent
    initialize_with :custom_function

    def to_s
      super(id, data)
    end

    def id = "bootcamp-custom-function-editor"

    def data
      {
        custom_function: {
          uuid: custom_function.uuid,
          name: custom_function.name,
          description: custom_function.description,
          code: custom_function.code,
          tests: custom_function.tests
        },
        links: {
          custom_fns_dashboard: Exercism::Routes.bootcamp_custom_functions_url,
          update_custom_fns: Exercism::Routes.api_bootcamp_custom_function_url(custom_function),
          get_custom_fns: Exercism::Routes.api_bootcamp_custom_functions_url,
          get_custom_fns_for_interpreter: Exercism::Routes.for_interpreter_api_bootcamp_custom_functions_url
        }
      }
    end
  end
end
