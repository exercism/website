module Metrics
  NUM_USERS_KEY = "metrics_num_users".freeze
  NUM_SOLUTIONS_KEY = "metrics_num_solutions".freeze
  NUM_SUBMISSIONS_KEY = "metrics_num_submissions".freeze
  NUM_DISCUSSIONS_KEY = "metrics_num_discussions".freeze

  class << self
    { users: User,
      solutions: Solution,
      submissions: Submission,
      discussions: Mentor::Discussion }.each do |key, klass|
      redis_key = Metrics.const_get("num_#{key}_key".upcase)

      define_method "num_#{key}" do
        Exercism.redis_cache_client.get(redis_key)
      end

      define_method "increment_num_#{key}!" do
        Exercism.redis_cache_client.incr(redis_key)
      end

      define_method "set_num_#{key}!" do
        return if send("num_#{key}").to_i > 350_000

        count = ActiveRecord::Base.connection.select_value("
          SELECT table_rows
          FROM information_schema.tables
          WHERE table_schema = '#{ActiveRecord::Base.connection.current_database}'
            AND table_name = '#{klass.table_name}';
        ")
        Exercism.redis_cache_client.set(redis_key, count)
      end
    end
  end
end
