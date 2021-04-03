class User::ReputationToken < ApplicationRecord
  include IsParamaterisedSTI
  include Webpacker::Helper

  self.class_suffix = :token
  self.i18n_category = :user_reputation_tokens

  scope :unseen, -> { where(seen: false) }

  # Reason, category and value can be set statically in
  # children. The determine_reason, etc methods can be overriden
  # in child classes for situations where logic is required.
  %i[reason category levels value values].each do |attr|
    define_singleton_method attr do |val|
      instance_variable_set("@#{attr}", val)
    end
  end

  before_validation on: :create do
    self.uuid = SecureRandom.compact_uuid

    # TODO: What's a nicer way of doing this double lookup?
    self.reason = self.class.instance_variable_get("@reason")
    self.category = self.class.instance_variable_get("@category")

    # TODO: Validate level is in levels if present
  end

  before_validation do
    # Value is mutable if the level changes
    self.value = self.determine_value
  end

  after_save do
    # We're updating in a single query instead of two queries to avoid race-conditions
    summing_sql = Arel.sql("(#{user.reputation_tokens.select('SUM(value)').to_sql})")
    User.where(id: user.id).update_all(reputation: summing_sql)
  end

  def params=(hash)
    self.level = hash.delete(:level) if hash.key?(:level)
    self.external_url = hash.delete(:external_url) if hash.key?(:external_url)

    super(hash)
  end

  # Set these methods to be returned as symbols
  %i[category reason level].each do |attr|
    define_method attr do
      super().try(&:to_sym)
    end
  end

  protected
  def determine_value
    return self.class.instance_variable_get("@value") if self.class.instance_variable_defined?("@value")

    # TODO: Test this
    raise ReputationTokenLevelUndefined if level.blank?

    values = self.class.instance_variable_get("@values")
    values[level.to_sym]
  end

  private
  def cacheable_rendering_data
    data = {
      id: uuid,
      url: "#", # TODO: Fill this in
      value: value,
      text: text,
      icon_url: icon_url,
      internal_url: internal_url,
      external_url: external_url,
      is_seen: seen,
      awarded_at: created_at.iso8601
    }

    if track
      data[:track] = {
        title: track.title,
        icon_url: track.icon_url
      }
    end

    data
  end

  # TODO: Override in children classes
  def icon_url
    return exercise.icon_url if exercise

    # TODO: Choose an icon
    asset_pack_url(
      "media/images/icons/reputation.svg",
      host: Rails.application.config.action_controller.asset_host
    )
  end

  # TODO: Override in children classes
  def internal_url
    nil
  end
end
