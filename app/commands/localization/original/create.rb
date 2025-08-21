class Localization::Original::Create
  include Mandate

  initialize_with :type, :key, :value, :object_id

  def call
    Localization::Original.create!(
      key: key,
      value: value,
      type: type,
      object_id: object_id
    ).tap do |original|
      original.translations.create!(
        locale: "en",
        value: value
      )
    end
  end
end
