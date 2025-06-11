module CachedFind
  extend ActiveSupport::Concern

  included do
    after_save :clear_cached_find_cache
    after_destroy :clear_cached_find_cache
  end

  class_methods do
    def cached
      all.extending(CachedFind::RelationMethods)
    end
  end

  module RelationMethods
    def find(id)
      Rails.cache.fetch("#{klass.name.underscore}:id:#{id}", expires_after: 1.hour) do
        super(id).attributes
      end.then { |attrs| klass.instantiate(attrs) } # rubocop:disable Style/MultilineBlockChain
    end

    def find_by!(attributes)
      return super if !attributes.is_a?(Hash) || attributes.size != 1

      value = XXhash.xxh32(attributes.values.first) # Don't trust this!

      cache_key = "#{klass.name.underscore}:#{attributes.keys.first}:hashed:#{value}"

      Rails.cache.fetch(cache_key, expires_after: 1.hour) do
        super(attributes).attributes
      end.then { |attrs| klass.instantiate(attrs) } # rubocop:disable Style/MultilineBlockChain
    end

    def find_by(attributes)
      find_by!(attributes)
    rescue ActiveRecord::RecordNotFound
      # We can happily return nil
    end
  end

  private
  def clear_cached_find_cache
    Rails.cache.delete("#{self.class.name.underscore}:id:#{id}")

    previous_changes.each_key do |key|
      cache_key = "#{self.class.name.underscore}:#{key}:hashed:#{XXhash.xxh32(previous_changes[key].last)}"
      Rails.cache.delete(cache_key)
    end
  end
end
