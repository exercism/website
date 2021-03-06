module V2ETL
  module DataProcessors
    class ProcessAnonymousMode
      include Mandate

      def call
        # TODO: Do we want to continue suppurting this?
        # Should we let these people know.
        Mentor::Request.
          joins("INNER JOIN user_tracks ON 
            user_tracks.user_id = mentor_requests.student_id AND
            user_tracks.track_id = mentor_requests.track_id"
          ).
          where('user_tracks.anonymous': true).
          destroy_all

        Mentor::Discussion.joins(solution: :exercise).
          joins("INNER JOIN user_tracks ON 
            user_tracks.user_id = solutions.user_id AND
            user_tracks.track_id = exercises.track_id"
          ).
          where('user_tracks.anonymous': true).
          update_all('anonymous_mode': true)

        UserTrack.connection.remove_column :user_tracks, :anonymous
      end
    end
  end
end

