class User::ReputationToken < ApplicationRecord
  include IsParamaterisedSTI
  self.class_suffix = :token
  self.i18n_category = :user_reputation_tokens

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
    self.external_link = hash.delete(:external_link) if hash.key?(:external_link)

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
      value: value,
      text: text,
      icon_name: icon_name,
      internal_link: internal_link,
      external_link: external_link,
      awarded_at: created_at.iso8601
    }

    if track
      data[:track] = {
        title: track.title,
        icon_name: track.icon_name
      }
    end

    data
  end

  # TODO: Override in children classes
  def icon_name
    return exercise.icon_name if exercise
    return track.icon_name if track

    :reputation # TODO: Choose an icon
  end

  # TODO: Override in children classes
  def internal_link
    nil
  end
end
