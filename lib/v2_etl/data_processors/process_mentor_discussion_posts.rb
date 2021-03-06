module V2ETL
  module DataProcessors
    class ProcessMentorDiscussionPosts
      include Mandate

      def call
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

        # Delete discussions with no posts
        Mntor::Discussion.where.not(
          id: Mentor::DiscussionPost.select(:discussion_id)
        ).delete_all
      end
    end
  end
end
