module API
  class CommunityVideosController < BaseController
    def lookup
      video = CommunityVideo::Retrieve.(params[:video_url])
      serialized = video.attributes.slice(*%w[title platform channel_name channel_url thumbnail_url url])
      render json: { community_video: serialized }.to_json
    rescue InvalidCommunityVideoUrl
      render_400(:invalid_community_video_url)
    end

    def create
      if params[:track_slug].present?
        begin
          track = Track.find(params[:track_slug])
        rescue ActiveRecord::RecordNotFound
          return render_track_not_found
        end

        begin
          exercise = track.exercises.find(params[:exercise_slug]) if params[:exercise_slug].present?
        rescue ActiveRecord::RecordNotFound
          return render_exercise_not_found
        end
      end

      CommunityVideo::Create.(
        params[:video_url],
        current_user,
        title: params[:title],
        author: (params[:submitter_is_author] ? current_user : nil),
        track:,
        exercise:
      )

      render json: {}
    rescue InvalidCommunityVideoUrl
      render_400(:invalid_community_video_url)
    end
  end
end
