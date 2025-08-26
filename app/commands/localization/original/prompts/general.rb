class Localization::Original::Prompts::General
  include Mandate

  initialize_with :original, :locale

  def call
    Localization::Original::Prompts::GenericPrompt.(original, locale, context)
  end

  private
  def context
    <<~PROMPT
      ## Context

      This is a string that's rendered on the website.

      #{original.context}
    PROMPT
  end
end
