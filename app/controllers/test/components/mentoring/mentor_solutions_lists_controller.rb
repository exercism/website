class Test::Components::Mentoring::MentorSolutionsListsController < ApplicationController
  def show
    @solutions = [
      {
        trackTitle: "Ruby",
        trackIconUrl: "https://assets.exercism.io/tracks/ruby-hex-white.png",
        menteeAvatarUrl: "https://robohash.org/exercism",
        menteeHandle: "mentee",
        exerciseTitle: "Series",
        isStarred: true,
        haveMentoredPreviously: true,
        status: "First timer",
        updatedAt: 1.year.ago.iso8601,
        url: "https://exercism.io/solutions/1"
      }
    ]
  end
end
