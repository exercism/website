class Metric < ApplicationRecord
  serialize :params, JSON
  serialize :coordinates, JSON # Stored as [latitude, longitude]

  belongs_to :track, optional: true
  belongs_to :user, optional: true

  before_create do
    self.uniqueness_key = generate_uniqueness_key!
    self.params = {} if self.params.blank?
  end

  def generate_uniqueness_key! = "#{type.demodulize}|#{guard_params}"

  # By default, use the request's remote IP to determine the country code.
  # Metrics can opt-out by overriding this method and returning nil.
  def store_country_code? = true

  # Should a user be publically doxed as part of this action.
  # The guide should be whether this action is publically associated
  # with them already on the website (e.g. publishing a solution)
  def user_public? = false

  def to_broadcast_hash
    {
      type: type.underscore.split('/').last,
      id:,

      coordinates: broadcast_coordinates,
      occurred_at:
    }.tap do |hash|
      if store_country_code?
        hash[:country_code] = country_code&.downcase
        hash[:country_name] = country_name
      end

      if track
        hash[:track] = {
          title: track.title,
          icon_url: track.icon_url
        }
      end

      if respond_to?(:pull_request)
        hash[:pull_request] = {
          html_url: pull_request.data[:html_url]
        }
      end

      if respond_to?(:solution) && solution.published?
        hash[:published_solution_url] = Exercism::Routes.published_solution_url(solution)
      end

      if respond_to?(:exercise)
        hash[:exercise] = {
          title: exercise.title,
          icon_url: exercise.icon_url,
          exercise_url: Exercism::Routes.track_exercise_url(exercise.track, exercise.slug)
        }
      end

      if user_public? && user
        hash[:user] = {
          handle: user.handle,
          avatar_url: user.avatar_url,
          links: {
            self: user.profile? ?
            Exercism::Routes.profile_path(user) : nil
          }
        }
      end
    end
  end

  def broadcast_coordinates
    return coordinates if coordinates.present?

    # Otherwise we just return some sane coordinate for the map
    # This is for things like GitHub where we don't know where
    # things are actually happening.
    [
      [41.6919, -73.8642],
      [35.6897, 139.6895],
      [53.4809, -2.2374],
      [-29.0, 24.0],
      [-35.6535, 137.6262],
      [30.4032, -97.753]
    ].sample
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
