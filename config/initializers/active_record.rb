class ActiveRecord::Base
  def self.disable_sti!
    self.inheritance_column = 'does_not_have_one'
  end
end
