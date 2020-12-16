class AddUuidToMentorRequestsAndDiscussions < ActiveRecord::Migration[6.1]
  def change
    add_column :solution_mentor_requests, :uuid, :string, null: true
    add_column :solution_mentor_discussions, :uuid, :string, null: true

    Solution::MentorRequest.find_each{|mr|mr.update(uuid: SecureRandom.compact_uuid)}
    Solution::MentorDiscussion.find_each{|mr|mr.update(uuid: SecureRandom.compact_uuid)}

    change_column_null :solution_mentor_requests, :uuid, false
    change_column_null :solution_mentor_discussions, :uuid, false
  end
end
