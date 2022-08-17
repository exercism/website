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
    alias base_exec_queries exec_queries
    def exec_queries(...)
      # puts "exec queries"
      Exercism::ActiveRecordCache.get_or_set(to_sql) do
        base_exec_queries(...)
      end
    end
  end
end

module ActiveRecord
  module Querying
    alias base_find_by_sql find_by_sql
    def find_by_sql(sql, binds = [], preparable: nil, &block)
      # puts "find_by_sql"
      Exercism::ActiveRecordCache.get_or_set(sql, binds) do
        base_find_by_sql(sql, binds, preparable:, &block)
      end
    end

    #     alias base__load_from_sql _load_from_sql
    #     def _load_from_sql(...)
    #       puts "_load_from_sql"
    #       base__load_from_sql(...)
    #     end
  end
end

module Exercism
  class ActiveRecordCache
    include Singleton
    def self.enable! = instance.enable!
    def self.reset! = instance.reset!
    def self.get_or_set(...) = instance.get_or_set(...)

    def initialize
      reset!
    end

    def reset!
      @cache = {}
      @enabled = false
    end

    def enable!
      @enabled = true
    end

    def get_or_set(sql, binds = [])
      # Yield and get out of here unless this is enabled
      return yield unless @enabled

      return @cache[sql][binds] if @cache.key?(sql) && @cache[sql].key?(binds)

      @cache[sql] ||= {}
      @cache[sql][binds] = yield
    end
  end
end
