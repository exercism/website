class Localization::Original::Translate
  include Mandate

  initialize_with :original, :locale

  def call
    begin
      original.translations.create!(locale: locale)
    rescue ActiveRecord::RecordNotUnique
      # We just continue even if it exists
    end

    LLM::ExecGeminiFlash.(prompt, endpoint)
  end

  private
  def endpoint
    "localization_translated?original_uuid=#{original.uuid}&locale=#{locale}"
  end

  def prompt
    # Use the helper class to generate a prompt
    case original.type
    when :unknown, :website_server_side, :website_client_side
      klass_name = "general"
    else
      klass_name = original.type
    end

    klass = "localization/original/prompts/#{klass_name}".camelize.constantize
    klass.(original, locale)
  end
end
