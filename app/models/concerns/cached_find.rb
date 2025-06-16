module CachedFind
  extend ActiveSupport::Concern

  included do
    # These must be done like this with blocks rather than symbols
    # for reasons I really have no idea about. They're just not called otherwise.
    after_update_commit { clear_cached_find_cache! }
    after_destroy_commit { clear_cached_find_cache! }

    def clear_cached_find_cache!
      Rails.cache.delete("mc:#{self.class.name.underscore}:id:#{id}")

      self.class.cached_find_keys.each do |key|
        value = self.public_send(key)
        hashed = XXhash.xxh32(value.to_s)
        cache_key = "mc:#{self.class.name.underscore}:#{key}:hashed:#{hashed}"
        Rails.cache.delete(cache_key)
      end

      self.previous_changes.each do |key, value|
        next unless self.class.cached_find_keys.include?(key.to_sym)

        hashed = XXhash.xxh32(value.first.to_s)
        cache_key = "mc:#{self.class.name.underscore}:#{key}:hashed:#{hashed}"
        Rails.cache.delete(cache_key)
      end
    end
  end

  class_methods do
    # List of attributes we're willing to cache on (for find_by)
    # Extend this per model to add find_by(...) support
    def cached_find_keys = %i[]

    def cached
      all.extending(CachedFind::RelationMethods)
    end
  end

  module RelationMethods
    def find(id)
      Rails.cache.fetch("mc:#{klass.name.underscore}:id:#{id}", expires_after: 1.hour) do
        super(id).attributes
      end.then { |attrs| klass.instantiate(attrs) } # rubocop:disable Style/MultilineBlockChain
    end

    def find_by!(attributes)
      return super if !attributes.is_a?(Hash) || attributes.size != 1

      key, value = attributes.first
      return find(value) if key.to_sym == :id

      return super unless klass.cached_find_keys.include?(key.to_sym)

      # We can't trust the values, so we hash them
      hashed_value = XXhash.xxh32(value.to_s)
      cache_key = "mc:#{klass.name.underscore}:#{attributes.keys.first}:hashed:#{hashed_value}"

      Rails.cache.fetch(cache_key, expires_after: 1.hour) do
        super.attributes_before_type_cast
      end.then { |attrs| klass.instantiate(attrs) } # rubocop:disable Style/MultilineBlockChain
    end

    def find_by(attributes)
      find_by!(attributes)
    rescue ActiveRecord::RecordNotFound
      # We can happily return nil
    end
  end
end
