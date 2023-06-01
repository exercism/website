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

class ActiveRecord::Relation
  def to_active_relation
    self
  end
end

class Array
  def to_active_relation
    return User.none if empty?

    ids = map(&:id)
    klass = first.class.base_class
    klass.where(id: ids).
      order(Arel.sql("FIND_IN_SET(id, '#{ids.join(',')}')"))
  end
end
