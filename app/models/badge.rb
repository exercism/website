class Badge < ApplicationRecord
  disable_sti!

  def type
    super.to_sym
  end

  # TODO: Temporary method
  def name
    type.to_s.titleize
  end
end
