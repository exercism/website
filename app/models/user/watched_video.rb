class User::WatchedVideo < ApplicationRecord
  belongs_to :user
  enum video_provider: { youtube: 1, vimeo: 2 }
  enum context: {
    unknown: 0,
    dashboard: 1,
    editor: 2,
    solution_main: 3,
    solution_dig_deeper: 4,
    blog: 5,
    challenge: 6,
    challenge_external: 7,
    brief_introduction: 8,
    community_interviews: 9,
    community: 10,
    generic_exercises: 11,
    tracks_about: 12,
    track_summary: 13,
    exercises_external: 14
  }
end
