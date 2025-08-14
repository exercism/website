class Localization::Original::Create
  include Mandate

  initialize_with :key, :value, :context

  def call
    Localization::Original.create!(
      key: key,
      value: value,
      context: context
    ).tap do |original|
      original.translations.create!(
        locale: "en",
        value: value
      )
    end
  end
end
