module CachedFind
  extend ActiveSupport::Concern

  included do
    # These must be done like this with blocks rather than symbols
    # for reasons I really have no idea about. They're just not called otherwise.
    after_update_commit { clear_cached_find_cache }
    after_destroy_commit { clear_cached_find_cache }

    private
    def clear_cached_find_cache
      p "DELETE #{self.class.name.underscore}:id:#{id}"
      Rails.cache.delete("#{self.class.name.underscore}:id:#{id}")

      self.class.cached_find_keys.each do |key|
        value = self.public_send(key)
        hashed = XXhash.xxh32(value.to_s)
        cache_key = "#{self.class.name.underscore}:#{key}:hashed:#{hashed}"
        p "DELETE #{cache_key}"
        Rails.cache.delete(cache_key)
      end
    end
  end

  class_methods do
    # List of attributes we're willing to cache on (for find_by)
    def cached_find_keys = %i[] # Extend this per model

    def cached
      all.extending(CachedFind::RelationMethods)
    end
  end

  module RelationMethods
    def find(id)
      p "LOOKUP #{self.class.name.underscore}:id:#{id}"
      Rails.cache.fetch("#{klass.name.underscore}:id:#{id}", expires_after: 1.hour) do
        super(id).attributes
      end.then { |attrs| klass.instantiate(attrs) } # rubocop:disable Style/MultilineBlockChain
    end

    def find_by!(attributes)
      p "LOOKUPS #{attributes}"
      return super if !attributes.is_a?(Hash) || attributes.size != 1

      key, value = attributes.first
      return find(value) if key.to_sym == :id

      return super unless klass.cached_find_keys.include?(key.to_sym)

      # We can't trust the values, so we hash them
      hashed_value = XXhash.xxh32(value.to_s)
      cache_key = "#{klass.name.underscore}:#{attributes.keys.first}:hashed:#{hashed_value}"
      p "LOOKUPF #{cache_key}"

      #     Rails.cache.fetch(cache_key, expires_after: 1.hour) do
      #       super(attributes).attributes
      columns = klass.column_names
      row = klass.where(key => value).limit(1).pluck(*columns).first
      attrs = Hash[columns.zip(row)]
      klass.instantiate(attrs)
      #     end.then { |attrs| klass.instantiate(attrs) }
    end

    def find_by(attributes)
      find_by!(attributes)
    rescue ActiveRecord::RecordNotFound
      # We can happily return nil
    end
  end
end
