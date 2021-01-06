class AddUuidToSolutionMentorDiscussionPosts < ActiveRecord::Migration[6.1]
  def change
    add_column :solution_mentor_discussion_posts, :uuid, :string, null: true

    Solution::MentorDiscussionPost.find_each{ |p| p.update(uuid: SecureRandom.compact_uuid) }

    change_column_null :solution_mentor_discussion_posts, :uuid, false
  end
end
