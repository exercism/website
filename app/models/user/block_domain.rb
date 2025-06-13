class User::BlockDomain < ApplicationRecord
  include CachedFind

  after_save_commit :clear_cache
  after_destroy_commit :clear_cache

  def self.blocked?(user: nil, email: nil)
    raise "Specify either user or email" unless user || email

    domain = Mail::Address.new(email || user.email).domain
    Rails.cache.fetch(cache_key, expires_in: 1.hour) do
      User::BlockDomain.where(domain:).exists?
    end
  end

  private
  def clear_cache
    Rails.cache.delete(cache_key)
  end

  def cache_key = "user_block_domain:#{domain}"
end
