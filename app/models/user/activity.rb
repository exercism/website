# This class uses some caching logic to avoid n+1 lookups when
# rendering activities in the browser.
#
# Each activity is expected to define a `cachable_rendering_data`
# method, which should call super.({...}) for any data that is
# used in rendering and cachable. For example, you might cache an
# exercise title or icon. This should all be data that rarely
# changes. Where an actual object is needed to render (e.g. an
# iteration to render the React iteration summary component) do
# not cache it, but append it to the rendered data OpenStruct
# (see User::Activities::SubmittedIterationActivity for an example).
#
# Caches can be expired by setting rendering_data_cache to {}
# Activities will then rebuild the cache next time they load.
#
# Activities are also expected to define the following:
# - url
# - guard_params (a list of params that ensure we don't get duplicates
# for the same object. Normally the object that this activity is about
# surfices)
# - grouping_params (a list of things where we would only show one
# activity about this in a list. e.g. a single activity)
class User::Activity < ApplicationRecord
  extend Mandate::Memoize

  # This provides a params class method to the child classes,
  # which they can use for setting parameters.
  # For each key passed in via params, we retrieve that
  # key from the params on demand, and cache it.
  def self.params(*keys)
    keys.each do |key|
      define_method key do
        iv = "@params_#{key}"
        instance_variable_get(iv) ||
          instance_variable_set(iv, retrieve_param(key))
      end
    end
  end

  belongs_to :user
  belongs_to :track, optional: true
  belongs_to :solution, optional: true

  before_create do
    self.uniqueness_key = "#{user_id}|#{type_key}|#{guard_params}"
    self.occurred_at = Time.current unless self.occurred_at
    self.params = {} unless self.params

    self.version = latest_i18n_version
    self.rendering_data_cache = cachable_rendering_data
  end

  def rendering_data
    data = rendering_data_cache
    if data.blank?
      data = cachable_rendering_data
      update!(rendering_data_cache: data)
    end

    data.with_indifferent_access.
      merge('occurred_at' => occurred_at)
  end

  # This maps
  # {discussion: Solution::MentorDiscussion.find(186)}
  # to
  # {discussion: "gid://exercism/Solution::MentorDiscussion/186"}
  #
  # Any non-object params are left as the were passed in.
  def params=(hash)
    @input_params = hash
    self[:params] = hash.transform_values do |v|
      v.respond_to?(:to_global_id) ? v.to_global_id.to_s : v
    end
  end

  def cachable_rendering_data
    {
      text: text,
      url: url
    }
  end

  private
  def text
    I18n.t("user_activities.#{i18n_key}.#{version}", i18n_params).strip
  end

  def type_key
    type.split("::").last.underscore.split("_activity").first.to_sym
  end

  # This reverses params= to explode back out
  # {discussion: "gid://exercism/Solution::MentorDiscussion/186"}
  # to
  # {discussion: Solution::MentorDiscussion.find(186)}
  #
  # Any non-object params are left as the were passed in.
  def retrieve_param(key)
    return @input_params[key] if @input_params

    value = self.params[key.to_s]
    GlobalID::Locator.locate(value) || value
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

  def i18n_params
    {}
  end
end
