class CommunityVideo
  class Create
    include Mandate

    initialize_with :video_url, :submitted_by, title: nil, author: nil, track: nil, exercise: nil

    def call
      Retrieve.(video_url).tap do |video|
        video.title = title if title.present?

        video.attributes = {
          submitted_by:,
          author:,
          track:,
          exercise:
        }
        video.save!
      end
    end
  end
end
