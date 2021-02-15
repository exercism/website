# ** Introduction  **
#
# This class allows for the creation of paramaterised
# STI classes, with guards for uniquness, i18n versioning
# and cachablity. This powers notifications, user activities
# and reputation tokens throughout Exercism.
#
# ** Caching  **
## This class uses some caching logic to avoid n+1 lookups when
# rendering the models (notifications, activities, etc) in the browser.
#
# Each implementing class is expected to define a `cachable_rendering_data`
# which contains any data that can be safely cached for rendering.
# For example, you might cache an exercise title or icon. This should
# all be data that rarely changes. Where an actual object is needed
# to render (e.g. an iteration to render the React iteration summary
# component) do not cache it, but override non_cachable_rendering_data
# instead.
#
# Each child class can also override the `cachable_rendering_data`
# method, which should call super.({...}) for any data that is
# used in rendering and cachable.
#
# Caches can be expired by setting rendering_data_cache to {}
# Objects will then rebuild the cache next time they load.
#
# ** Params **
# A params hash can be set at creation time. Any objects specified
# in it will be stored using Rails' GlobalID functionality.
# Chldren can specify the following in their classes:
# params :foo, :bar
#
# This will define methods for the params, load and memoize them on-demand
#
# ** Uniqueness **
# This supports uniqueness via a uniqueness_key. This is automatically
# populated by using children's guard_params. The combination of those
# guard_params are merged with a users's id and the type of the object
# to create a unique identifier. Children can override the uniquness_key
# if they need to, but this is discouraged
#
# ** Usage **
# Use this module by adding the following code:
#
# include IsParamaterisedSTI
# self.class_suffix = :activity
# self.i18n_category = :user_activities
#
# The class suffix is the final repetitive part of the child models
# For example, we use it to remove "_activity" from
# user/activities/submittied_iteration_activity to give us
# "submibtted_iteration"
#
# The i18n category is the file in the the config/locales containing
# the translation data for the text of each object

module IsParamaterisedSTI
  extend ActiveSupport::Concern

  include ActionView::Helpers::SanitizeHelper
  include ActionView::Helpers::AssetUrlHelper
  include Webpacker::Helper
  extend Mandate::Memoize

  included do
    cattr_accessor :class_suffix, :i18n_category

    before_create do
      self.uniqueness_key = "#{user_id}|#{type_key}|#{guard_params}"
      self.params = {} if self.params.blank?
      self.version = latest_i18n_version
      self.rendering_data_cache = cachable_rendering_data
    end
  end

  class_methods do
    # This provides a params class method to the child classes,
    # which they can use for setting parameters.
    # For each key passed in via params, we retrieve that
    # key from the params on demand, and cache it.
    def params(*keys)
      keys.each do |key|
        define_method key do
          iv = "@params_#{key}"
          instance_variable_get(iv) ||
            instance_variable_set(iv, retrieve_param(key))
        end
      end
    end
  end

  def rendering_data
    data = rendering_data_cache
    if data.blank?
      data = cachable_rendering_data
      update!(rendering_data_cache: data)
    end

    data.with_indifferent_access.
      merge(non_cachable_rendering_data)
  end

  # Save each class from manually overriding this
  def non_cachable_rendering_data
    {}
  end

  def text
    # TODO: Add test for sanitizing here.
    I18n.t(
      "#{i18n_category}.#{i18n_key}.#{version}",
      i18n_params.transform_values { |v| sanitize(v.to_s) }
    ).strip
  end

  memoize
  def type_key
    type.split("::").last.underscore.gsub(/_#{class_suffix}$/, '').to_sym
  end

  memoize
  def i18n_key
    self.class.name.underscore.split('/').last.gsub(/_#{class_suffix}$/, '').to_sym
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
  def retrieve_param(key)
    value = self.params[key.to_s]
    GlobalID::Locator.locate(value) || value
  end

  def latest_i18n_version
    I18n.backend.send(:init_translations)
    I18n.backend.send(:translations)[:en][i18n_category][i18n_key].keys.first
  rescue StandardError
    raise "Missing i18n key for this notification"
  end

  def i18n_params
    {}
  end
end
