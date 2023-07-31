class SerializeCommunityStories
  include Mandate

  initialize_with :stories

  def call
    stories.includes(:interviewee).map do |story|
      SerializeCommunityStory.(story)
    end
  end

  class SerializeCommunityStory
    include Mandate

    initialize_with :story

    def call
      {
        title: story.title,
        thumbnail_url: story.thumbnail_url,
        interviewee: {
          name: story.interviewee.name,
          handle: story.interviewee.handle,
          flair: story.interviewee.flair,
          avatar_url: story.interviewee.avatar_url,
          links: {
            profile: story.interviewee.profile ? Exercism::Routes.profile_url(story.interviewee) : nil
          }
        },
        links: {
          self: Exercism::Routes.community_story_path(story)
        }
      }
    end
  end
end
