class Notification < ApplicationRecord
  #TYPES = {
  #  mentor_discussion_started: {version: 1},
  #  mentor_reply: {version: 1}
  #}

  #disable_sti!

  enum email_status: [:pending, :skipped, :sent, :failed]

  belongs_to :user

  before_create do
    self.version = latest_i18n_version
  end

  #def type
  #  super.to_sym
  #end

  def text
    I18n.t("notifications.#{i18n_key}.#{version}", i18n_params).strip
  end

  # This maps 
  # {discussion: Solution::MentorDiscussion.find(186)}
  # to
  # {discussion: "gid://exercism/Solution::MentorDiscussion/186"}
  #
  # Any non-object params are left as the were passed in.
  def params=(hash)
    self[:params] = hash.each_with_object({}) do |(k,v), h|
      h[k] = v.respond_to?(:to_global_id) ? v.to_global_id.to_s : v
    end
  end

  # This reverses params= to explode back out
  # {discussion: "gid://exercism/Solution::MentorDiscussion/186"}
  # to
  # {discussion: Solution::MentorDiscussion.find(186)}
  #
  # Any non-object params are left as the were passed in.
  private
  def params
    super.each_with_object({}) do |(k,v), h|
      h[k.to_sym] = GlobalID::Locator.locate(v) || v
    end
  end

  private
  def latest_i18n_version
    I18n.backend.send(:init_translations)
    I18n.backend.send(:translations)[:en][:notifications][i18n_key].keys.first
  rescue
    raise "Missing key for this notification"
  end

  def i18n_key
    self.class.name.underscore.split('/').last.gsub(/_notification$/, '').to_sym
  end
end
