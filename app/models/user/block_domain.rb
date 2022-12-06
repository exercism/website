class User::BlockDomain < ApplicationRecord
  def self.blocked?(user_or_email)
    email = user_or_email.is_a?(User) ? user_or_email.email : user_or_email
    domain = Mail::Address.new(email).domain
    User::BlockDomain.where(domain:).exists?
  end
end
