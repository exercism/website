class Localization::Text::AddToLocalization
  include Mandate

  initialize_with :text, :context

  def call
    Localization::Original::Create.(key, text, context).tap do |original|
      Localization::Original::Translate.(original, "hu")
    end
  rescue ActiveRecord::RecordNotUnique
    # If the key already exists, we do nothing.
  end

  private
  def key = Localization::Text::GenerateKey.(text)
end
