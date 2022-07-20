class Metric < ApplicationRecord
  serialize :params, JSON

  belongs_to :track, optional: true
  belongs_to :user, optional: true

  before_create do
    self.uniqueness_key = generate_uniqueness_key!
    self.params = {} if self.params.blank?
  end

  def generate_uniqueness_key! = "#{type.demodulize}|#{guard_params}"

  # This maps
  # {discussion: Mentor::Discussion.find(186)}
  # to
  # {discussion: "gid://exercism/Mentor::Discussion/186"}
  #
  # Any non-object params are left as the were passed in.
  def params=(hash)
    @initial_params = hash

    self.track = hash.delete(:track) if hash.key?(:track)
    self.user = hash.delete(:user) if hash.key?(:user)

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

  # This provides a params class method to the child classes,
  # which they can use for setting parameters.
  # For each key passed in via params, we retrieve that
  # key from the params on demand, and cache it.
  def self.params(*keys)
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
