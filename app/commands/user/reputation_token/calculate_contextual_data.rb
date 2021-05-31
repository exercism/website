class User::ReputationToken
  class CalculateContextualData
    include Mandate
    include ActionView::Helpers::TextHelper
    include ActionView::Helpers::NumberHelper

    def initialize(user_ids, earned_since: nil, track_id: nil, category: nil)
      @single_user = user_ids.is_a?(Integer)
      @user_ids = Array(user_ids)
      @earned_since = earned_since
      @track_id = track_id
      @category = category
    end

    def call
      single_user ? data.values.first : data
    end

    memoize
    def data
      user_ids.each_with_object({}) do |user_id, data|
        user_tuples = tuples.select { |t| t['user_id'] == user_id }.
          index_by { |t| t['type'] }.
          transform_keys { |k| k.split("::").last }

        code_contributions = user_tuples.dig("CodeContributionToken", 'num')
        code_reviews = user_tuples.dig("CodeReviewToken", 'num')
        code_merges = user_tuples.dig("CodeMergeToken", 'num')
        exercises_authored = user_tuples.dig("ExerciseAuthorToken", 'num')
        exercises_contributed = user_tuples.dig("ExerciseContributionToken", 'num')
        solutions_mentored = user_tuples.dig("MentoredToken", 'num')
        solutions_published = user_tuples.dig("PublishedSolutionToken", 'num')

        parts = []
        parts << format(code_contributions, "PR", "created") if code_contributions
        parts << format(code_reviews, "PR", "reviewed") if code_reviews
        parts << format(code_merges, "PR", "merged") if code_merges
        parts << format(exercises_authored, "exercise", "authored") if exercises_authored
        parts << format(exercises_contributed, "exercise contribution") if exercises_contributed
        parts << format(solutions_mentored, "solution", "mentored") if solutions_mentored
        parts << format(solutions_published, "solution", "published") if solutions_published

        data[user_id] = Data.new(
          parts.join(" • "),
          user_tuples.sum { |_k, v| v['total'] }
        )
      end
    end

    def format(value, thing, suffix = nil)
      suffix = suffix ? " #{suffix}" : ""
      "#{number_with_delimiter(value)} #{thing.pluralize(value)}#{suffix}"
    end

    memoize
    def tuples
      ts = User::ReputationToken.where(user_id: user_ids)
      ts = ts.where(category: category) if category
      ts = ts.where('earned_on >= ?', earned_since) if earned_since
      ts = ts.where(track_id: track_id) if track_id
      ts = ts.group(:user_id, :type).select("user_id, type, COUNT(*) as num, SUM(value) as total")

      ActiveRecord::Base.connection.select_all(ts.to_sql)
    end

    private
    attr_reader :user_ids, :single_user, :earned_since, :track_id, :category

    Data = Struct.new(:activity, :reputation)
  end
end
