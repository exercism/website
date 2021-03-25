class RemoveTypeFromMentorRequests < ActiveRecord::Migration[6.1]
  def change
    remove_column :solution_mentor_requests, :type
  end
end
