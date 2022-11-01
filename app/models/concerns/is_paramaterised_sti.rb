# ** Introduction  **
#
# This class allows for the creation of parameterized
# STI classes, with guards for uniqueness, i18n versioning
# and cacheability. This powers notifications, user activities
# and reputation tokens throughout Exercism.
#
# ** Caching  **
## This class uses some caching logic to avoid n+1 lookups when
# rendering the models (notifications, activities, etc) in the browser.
#
# Each implementing class is expected to define a `cacheable_rendering_data`
# which contains any data that can be safely cached for rendering.
# For example, you might cache an exercise title or icon. This should
# all be data that rarely changes. Where an actual object is needed
# to render (e.g., an iteration to render the React iteration summary
# component) do not cache it, but override non_cacheable_rendering_data
# instead.
#
# Each child class can also override the `cacheable_rendering_data`
# method, which should call super.({...}) for any data that is
# used in rendering and cacheable.
#
# Caches can be expired by setting rendering_data_cache to {}
# Objects will then rebuild the cache next time they load.
#
# ** Params **
# A params hash can be set at creation time. Any objects specified
# in it will be stored using Rails' GlobalID functionality.
# Children can specify the following in their classes:
# params :foo, :bar
#
# This will define methods for the params, load and memoize them on-demand
#
# ** Uniqueness **
# This supports uniqueness via a uniqueness_key. This is automatically
# populated by using children's guard_params. The combination of those
# guard_params are merged with a users' id and the type of the object
# to create a unique identifier. Children can override the uniqueness_key
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
# user/activities/submitted_iteration_activity to give us
# "submitted_iteration"
#
# The i18n category is the file in the config/locales containing
# the translation data for the text of each object

module IsParamaterisedSTI
  extend ActiveSupport::Concern

  include ActionView::Helpers::SanitizeHelper
  include Propshaft::Helper
  extend Mandate::Memoize

  included do
    serialize :params, JSON
    serialize :rendering_data_cache, JSON

    cattr_accessor :class_suffix, :i18n_category

    belongs_to :track, optional: true
    belongs_to :exercise, optional: true

    before_create do
      self.uniqueness_key = generate_uniqueness_key!
      self.params = {} if self.params.blank?
      self.version = latest_i18n_version
      self.rendering_data_cache = cacheable_rendering_data
    end

    before_save unless: :new_record? do
      # If any attributes have changed since the last time
      # this was saved, then rebuild the cache.
      non_cache_changes = (changed_attributes.keys - non_rendered_attributes.map(&:to_s) - [rendering_data_cache]).present?
      self.rendering_data_cache = cacheable_rendering_data if non_cache_changes
    end
  end

  class_methods do
    # This provides a params class method to the child classes,
    # which they can use for setting parameters.
    # For each key passed in via params, we retrieve that
    # key from the params on demand, and cache it.
    def params(*keys)
      keys.each do |key|
        iv = "@params_#{key}"

        define_method key do
          instance_variable_get(iv).presence || instance_variable_set(iv, retrieve_param(key))
        end

        define_method "#{key}=" do |val|
          params[key.to_s] = val.respond_to?(:to_global_id) ? val.to_global_id.to_s : val

          remove_instance_variable(iv) if instance_variable_defined?(iv)
        end
      end
    end
  end

  def regenerate_rendering_data!
    update!(rendering_data_cache: {})
  end

  def rendering_data
    data = rendering_data_cache
    if data.blank?
      data = cacheable_rendering_data
      update!(rendering_data_cache: data)
    end

    data.with_indifferent_access.merge(non_cacheable_rendering_data)
  end

  # Save each class from manually overriding this
  def non_cacheable_rendering_data = {}

  # Each class can define attributes that don't trigger
  # a recalculation of the recache on save
  def non_rendered_attributes
    []
  end

  def text
    I18n.t(
      "#{i18n_category}.#{i18n_key}.#{version}",
      **i18n_params.transform_values { |v| sanitize(v.to_s) }
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
  # {discussion: Mentor::Discussion.find(186)}
  # to
  # {discussion: "gid://exercism/Mentor::Discussion/186"}
  #
  # Any non-object params are left as the were passed in.
  def params=(hash)
    @initial_params = hash

    self.track = hash.delete(:track) if hash.key?(:track)
    self.exercise = hash.delete(:exercise) if hash.key?(:exercise)

    self[:params] = hash.each_with_object({}) do |(k, v), h|
      h[k.to_s] = v.respond_to?(:to_global_id) ? v.to_global_id.to_s : v
    end
  end

  # This reverses params= to explode back out
  # {discussion: "gid://exercism/Mentor::Discussion/186"}
  # to
  # {discussion: Mentor::Discussion.find(186)}
  #
  # Any non-object params are left as the were passed in.
  def retrieve_param(key)
    # If we've just set them, we don't need to look things
    # up again via globalid
    return @initial_params[key] if @initial_params&.key?(key)

    value = self.params[key.to_s]
    GlobalID::Locator.locate(value) || value
  end

  def latest_i18n_version
    I18n.backend.send(:init_translations)
    I18n.backend.send(:translations)[:en][i18n_category][i18n_key].keys.first
  rescue StandardError
    raise "Missing i18n key for this notification"
  end

  def i18n_params = {}

  def generate_uniqueness_key!
    k = [type_key, guard_params]
    # If we have a user_id column, include it in the key.
    # If not, don't bother.
    k.unshift(user_id) if respond_to?(:user_id)
    k.join("|")
  end
end
