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
      predefined: custom_function.predefined,
      tests: custom_function.tests,
      arity: custom_function.arity
    }
  end
end
