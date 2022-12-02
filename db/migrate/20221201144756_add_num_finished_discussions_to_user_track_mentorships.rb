class AddNumFinishedDiscussionsToUserTrackMentorships < ActiveRecord::Migration[7.0]
  def change
    unless Rails.env.production?
      add_column :user_track_mentorships, :num_finished_discussions, :mediumint, null: false, default: 0

      User::TrackMentorship.find_in_batches do |batch|
        ActiveRecord::Base.transaction(isolation: Exercism::READ_COMMITTED) do
          batch.each do |track_mentorship|
            num_finished_discussions_sql = Arel.sql(Mentor::Discussion.joins(:request).where(request: { track_id: track_mentorship.track_id}, mentor_id: track_mentorship.user_id).finished_for_student.select("COUNT(*)").to_sql)
            User::TrackMentorship.where(id: track_mentorship.id).update_all("num_finished_discussions = (#{num_finished_discussions_sql})")
          end
        end
      end
    end
  end
end
