class Test::Components::Mentoring::MentorConversationsListsController < ApplicationController
  def show
    @mentor = OpenStruct.new(conversations: conversations)
  end

  private
  def conversations
    [
      {
        trackIconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png",
        menteeAvatarUrl: "https://robohash.org/exercism",
        menteeHandle: "mentee",
        exerciseTitle: "Series",
        isStarred: true,
        haveMentoredPreviously: true,
        isNewIteration: true,
        postsCount: 15,
        updatedAt: 1.year.ago.iso8601,
        url: "https://exercism.io/conversations/1"
      }
    ]
  end
end
