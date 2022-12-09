class User::BlockDomain < ApplicationRecord
  def self.blocked?(user: nil, email: nil)
    raise "Specify either user or email" unless user || email

    domain = Mail::Address.new(email || user.email).domain
    User::BlockDomain.where(domain:).exists?
  end
end
