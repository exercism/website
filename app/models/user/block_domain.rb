class User::BlockDomain < ApplicationRecord
  include CachedFind

  after_save :clear_cache
  after_destroy :clear_cache

  def self.blocked?(user: nil, email: nil)
    raise "Specify either user or email" unless user || email

    domain = Mail::Address.new(email || user.email).domain
    Rails.cache.fetch("user_block_domain:#{domain}") do
      User::BlockDomain.where(domain:).exists?
    end
  end

  private
  def clear_cache
    Rails.cache.delete("user_block_domain:#{domain}")
  end
end
