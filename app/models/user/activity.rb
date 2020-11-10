class User::Activity < ApplicationRecord
  belongs_to :user
  belongs_to :track, optional: true

  before_create do
    self.version = latest_i18n_version
    self.uniqueness_key = "#{user_id}|#{type_key}|#{guard_params}"
    self.grouping_key = "#{user_id}|#{grouping_params}"
    self.occurred_at = Time.current unless self.occurred_at
  end

  def text
    I18n.t("user_activities.#{i18n_key}.#{version}", i18n_params).strip
  end

  def widget
    nil
  end

  def type_key
    type.split("::").last.underscore.split("_activity").first.to_sym
  end

  # This maps
  # {discussion: Solution::MentorDiscussion.find(186)}
  # to
  # {discussion: "gid://exercism/Solution::MentorDiscussion/186"}
  #
  # Any non-object params are left as the were passed in.
  def params=(hash)
    self[:params] = hash.transform_values do |v|
      v.respond_to?(:to_global_id) ? v.to_global_id.to_s : v
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
    super.each_with_object({}) do |(k, v), h|
      h[k.to_sym] = GlobalID::Locator.locate(v) || v
    end
  end

  def latest_i18n_version
    I18n.backend.send(:init_translations)
    I18n.backend.send(:translations)[:en][:user_activities][i18n_key].keys.first
  rescue StandardError
    raise "Missing i18n key for #{i18n_key}"
  end

  def i18n_key
    self.class.name.underscore.split('/').last.gsub(/_activity$/, '').to_sym
  end
end
