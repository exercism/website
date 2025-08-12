class Localization::Translation < ApplicationRecord
  extend I18n::Backend::Flatten

  enum :status, {
    unchecked: 0,
    proposed: 1,
    checked: 2
  }

  has_many :proposals, dependent: :destroy, class_name: "Localization::TranslationProposal"

  before_create do
    self.uuid = SecureRandom.uuid if uuid.blank?
    self.status = :checked if locale == "en"
  end

  def to_param = uuid

  def self.lookup(locale, key, options)
    # Return from cache if enabled and present
    cached_value = Localization::Cache::Retrieve.(locale, key)
    return cached_value if cached_value.present?

    # Look it up
    self.where(
      locale: locale.to_s,
      key: normalize_flat_keys(locale, key, options[:scope], '.')
    ).pick(:value).tap do |value|
      break unless value

      Localization::Cache::Store.(locale, key, value)

      # TODO: Push an Sidekiq job to update the translation with
      # the interpolated value if the count is under x or something
      # See https://github.com/svenfuchs/i18n-active_record/blob/0605ccf4a1dc9209fda1d5f781eedd24f26b1650/lib/i18n/backend/active_record/missing.rb#L41
      # Note, this might need to go above the cache bit?
    end
  end
end
