class User::BlockDomain < ApplicationRecord
  def self.blocked?(user)
    domain = Mail::Address.new(user.email).domain
    User::BlockDomain.where(domain:).exists?
  end
end
