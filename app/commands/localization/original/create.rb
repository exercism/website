class Localization::Original::Create
  include Mandate

  initialize_with :type, :key, :value, :about, :should_translate

  def call
    Localization::Original.create!(
      key: key,
      value: value,
      type: type,
      about: about,
      should_translate: should_translate
    ).tap do |original|
      original.translations.create!(
        locale: "en",
        value: value
      )
    end
  end
end
