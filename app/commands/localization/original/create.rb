class Localization::Original::Create
  include Mandate

  initialize_with :type, :key, :value, :about_id

  def call
    Localization::Original.create!(
      key: key,
      value: value,
      type: type,
      about_id: about_id
    ).tap do |original|
      original.translations.create!(
        locale: "en",
        value: value
      )
    end
  end
end
