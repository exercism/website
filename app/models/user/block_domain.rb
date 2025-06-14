class User::BlockDomain < ApplicationRecord
  include CachedFind

  after_save_commit { clear_cache }
  after_destroy_commit { clear_cache }

  def self.blocked?(user: nil, email: nil)
    raise "Specify either user or email" unless user || email

    domain = Mail::Address.new(email || user.email).domain
    Rails.cache.fetch(cache_key(domain), expires_in: 1.day) do
      User::BlockDomain.where(domain:).exists?
    end
  end

  def self.cache_key(domain) = "user_block_domain:#{domain}"

  private
  def clear_cache
    saved_change_to_domain.compact.each do |domain|
      Rails.cache.delete(self.class.cache_key(domain))
    end
  end
end
