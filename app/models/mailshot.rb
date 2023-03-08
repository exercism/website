class Mailshot < ApplicationRecord
  has_markdown_field :content, strip_h1: false

  def sent_to_audiences = super.to_a.map(&:to_sym).to_set

  def email_communication_preferences_key
    super&.to_sym
  end

  # This should return:
  # - an ActiveRecord relation that is paginatable
  # - a lambda that takes a record (from the relation) and returns the
  #   relevant user from it, or nil if there's no appropiate user (e.g. if a filter condition fails).
  def audience_for(type, slug)
    send("audience_for_#{type}", slug)
  end

  # rubocop:disable Lint/NonLocalExitFromIterator

  # This is pretty terribly slow and should only be used rarely.
  def audience_for_admins(_)
    [
      User.where("JSON_CONTAINS(roles, ?, '$')", %("admin")),
      ->(user) { user }
    ]
  end

  def audience_for_track(slug)
    [
      UserTrack.where(track: Track.find_by!(slug:)).includes(:user),
      lambda do |user_track|
        return unless user_track.num_completed_exercises >= 2

        user_track.user
      end
    ]
  end

  # rubocop:enable Lint/NonLocalExitFromIterator
end
