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

module ActiveRecord
  class Relation
    cattr_accessor :__ihid_cache__

    alias base_exec_main_query exec_main_query
    def exec_main_query(...)
      self.class.__ihid_cache__ ||= {}
      self.class.__ihid_cache__[to_sql] ||= base_exec_main_query(...)
    end
  end
end
