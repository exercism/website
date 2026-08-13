class User::ReputationToken < ApplicationRecord
  include IsParamaterisedSTI

  def self.cache_hash_for(user_id) = "users/#{user_id}/reputation"

  self.class_suffix = :token
  self.i18n_category = :user_reputation_tokens

  belongs_to :user

  scope :seen, -> { where(seen: true) }
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

  # This runs on create, update *and* destroy, which keeps both the
  # users.reputation and user_tracks.reputation denormalised columns in
  # sync in all three cases (tokens being deleted used to leave
  # user_tracks.reputation overstated).
  after_commit do
    ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
      reputation = user.reputation_tokens.sum(:value).to_i
      User.where(id: user.id).update_all(reputation:)
    end

    update_user_track_reputation!

    # Invalidate reputation cache for this user
    Exercism.redis_cache_client.del(self.class.cache_hash_for(user_id))
  end

  def params=(hash)
    self.level = hash.delete(:level) if hash.key?(:level)
    self.external_url = hash.delete(:external_url) if hash.key?(:external_url)
    self.earned_on = hash.delete(:earned_on) if hash.key?(:earned_on)

    super(hash)
  end

  # Set these methods to be returned as symbols
  %i[category reason level].each do |attr|
    define_method attr do
      super().try(&:to_sym)
    end
  end

  def seen!
    update_column(:seen, true)
  end

  protected
  def determine_value
    return self.class.instance_variable_get("@value") if self.class.instance_variable_defined?("@value")

    # TODO: Test this
    raise ReputationTokenLevelUndefined if level.blank?

    values = self.class.instance_variable_get("@values")
    values[level.to_sym]
  end

  def non_rendered_attributes
    %i[seen]
  end

  private
  def update_user_track_reputation!
    return if track_id.blank?

    user_track = UserTrack.find_by(user_id:, track_id:)
    return if user_track.blank?

    UserTrack::UpdateReputation.(user_track)
  end

  # Don't cahe seen as we don't need to recalculate
  # everything when it's marked as seen
  def non_cacheable_rendering_data
    {
      is_seen: seen?
    }
  end

  def cacheable_rendering_data
    data = {
      uuid:,
      value:,
      text:,
      icon_url:,
      internal_url:,
      external_url:,
      created_at: created_at.iso8601
    }

    if track
      data[:track] = {
        title: track.title,
        icon_url: track.icon_url
      }
    end

    data
  end

  def icon_url
    return exercise.icon_url if exercise

    "#{Rails.application.config.action_controller.asset_host}#{compute_asset_path("graphics/#{icon_name}.svg")}"
  end

  # To be overriden in children classes
  def icon_name = "reputation"

  # To be overriden in children classes
  def internal_url = nil
end
