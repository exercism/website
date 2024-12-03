class Mailshot < ApplicationRecord
  has_markdown_field :content, strip_h1: false

  def sent_to_audiences = super.to_a.to_set

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

  # This is pretty terribly slow and should only be used rarely.
  def audience_for_admins(_)
    [
      User.with_data.where("JSON_CONTAINS(user_data.roles, ?, '$')", %("admin")),
      ->(user) { user }
    ]
  end

  def audience_for_donors(_) = [User::Data.donors, ->(user_data) { user_data.user }]
  def audience_for_insiders(_) = [User.insiders, ->(user) { user }]

  def audience_for_reputation(min_rep)
    [
      User.where('reputation >= ?', min_rep),
      ->(user) { user }
    ]
  end

  def audience_for_recent(days)
    [
      User.with_data.where('user_data.last_visited_on >= ?', Time.current - days.to_i.days),
      lambda do |user|
        return unless user.iterations.count >= 2

        user
      end
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

  def audience_for_challenge(slug)
    [
      User::Challenge.where(challenge_id: slug).includes(:user),
      ->(uc) { uc.user }
    ]
  end

  def audience_for_bc_interested(_)
    [
      User::BootcampData.includes(:user),
      lambda do |bootcamp_data|
        return if bootcamp_data.paid?

        bootcamp_data.user
      end
    ]
  end

  def audience_for_bc_beginners(_)
    [
      User::Data.where(seniority: %i[absolute_beginner beginner]).includes(user: :bootcamp_data),
      lambda do |user_data|
        user = user_data.user
        return if user.bootcamp_data&.paid?

        user
      end
    ]
  end

  def audience_for_bc_juniors(_)
    [
      User::Data.where(seniority: :junior).includes(user: :bootcamp_data),
      lambda do |user_data|
        user = user_data.user
        return if user.bootcamp_data&.paid?

        user
      end
    ]
  end

  def audience_for_bc_mid_seniors(_)
    [
      User::Data.where(seniority: %i[mid senior]).includes(user: :bootcamp_data),
      lambda do |user_data|
        user = user_data.user
        return if user.bootcamp_data&.paid?

        user
      end
    ]
  end

  def audience_for_bc_unspecified(_)
    [
      User::Data.where(seniority: nil).includes(user: :bootcamp_data),
      lambda do |user_data|
        user = user_data.user
        return if user.bootcamp_data&.paid?

        user
      end
    ]
  end
end
