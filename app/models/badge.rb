class Badge < ApplicationRecord
  belongs_to :user

  def self.slug_to_type(slug)
    "badges/#{slug}_badge".camelize
  end

  def should_award?
    raise NotImplementedError
  end
end
