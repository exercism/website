class SerializeBootcampCustomFunctionSummary
  include Mandate

  initialize_with :custom_function

  def call
    return unless custom_function

    {
      name: custom_function.name,
      description: custom_function.description
    }
  end
end
