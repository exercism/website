class Localization::Original::Create
  include Mandate

  initialize_with :type, :key, :value, :data

  def call
    Localization::Original.create!(
      key: key,
      value: value,
      type: type,
      data: data
    ).tap do |original|
      original.translations.create!(
        locale: "en",
        value: value
      )
    end
  end
end
