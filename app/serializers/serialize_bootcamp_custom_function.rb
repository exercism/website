class SerializeBootcampCustomFunction
  include Mandate

  initialize_with :custom_function

  def call
    return unless custom_function

    {
      uuid: custom_function.uuid,
      name: custom_function.name,
      active: custom_function.active,
      description: custom_function.description,
      code: custom_function.code,
      tests: custom_function.tests,
      fn_name: custom_function.fn_name,
      fn_arity: custom_function.fn_arity
    }
  end
end
