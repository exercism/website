module V2ETL
  module DataProcessors
    class ProcessAnonymousMode
      include Mandate

      def call
        Mentor::Request.
          joins("INNER JOIN user_tracks ON 
            user_tracks.user_id = mentor_requests.student_id AND
            user_tracks.track_id = mentor_requests.track_id"
          ).
          where('user_tracks.anonymous_during_mentoring': true).
          destroy_all

        Mentor::Discussion.joins(solution: :exercise).
          joins("INNER JOIN user_tracks ON 
            user_tracks.user_id = solutions.user_id AND
            user_tracks.track_id = exercises.track_id"
          ).
          where('user_tracks.anonymous_during_mentoring': true).
          update_all('anonymous_mode': true)
      end
    end
  end
end

