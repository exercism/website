class ActiveRecord::Base
  def self.disable_sti!
    self.inheritance_column = 'does_not_have_one'
  end

  def self.find_create_or_find_by!(*args, &block)
    find_by!(*args)
  rescue ActiveRecord::RecordNotFound
    create_or_find_by!(*args, &block)
  end
end
