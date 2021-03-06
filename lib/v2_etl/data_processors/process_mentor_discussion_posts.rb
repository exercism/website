module V2ETL
  module DataProcessors
    class ProcessMentorDiscussionPosts
      include Mandate

      def call
        # TODO: This currently doesn't cope if there are more than one
        # set of mentor discussions for the same solution.
        #
        # The solution I want to take is to copy all the posts to
        # each discussion. It's not ideal but it's the only sane way.
        #
        # So the following steps need to be taken:
        # 1. Remove any mentor discussions where there are no
        #    posts by that mentor (ie where they joined then left)
        # 2. Add an idx flag to discussions, and populate with an
        #    incrementing number for each discussion on the same solution.
        # 3. For each idx in the db (1..n), do the pass below but have
        #    the idx as a join condition.
        # x. Remove the idx flag from discussions

        # Create a v3 mentor_discussion_post
        # for each v2 discussion_post
        ActiveRecord::Base.connection.execute(<<-SQL)
        INSERT INTO mentor_discussion_posts (
          uuid,
          iteration_id,
          discussion_id,
          user_id,
          content_markdown, content_html,
          seen_by_student, seen_by_mentor,
          created_at, updated_at
        )
        SELECT
          UUID(),
          v2_discussion_posts.iteration_id,
          mentor_discussions.id,
          v2_discussion_posts.user_id,
          v2_discussion_posts.content, v2_discussion_posts.html,
          TRUE, TRUE,
          v2_discussion_posts.created_at, v2_discussion_posts.updated_at
        FROM v2_discussion_posts
        INNER JOIN iterations
          ON v2_discussion_posts.iteration_id = iterations.id
        INNER JOIN mentor_discussions
          ON iterations.solution_id = mentor_discussions.solution_id
        WHERE v2_discussion_posts.user_id IS NOT NULL
        SQL
      end
    end
  end
end
