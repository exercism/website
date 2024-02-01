class User::WatchedVideo < ApplicationRecord
  belongs_to :user
  enum video_provider: { youtube: 1, vimeo: 2 }
  enum context: {
    unknown: 0,
    dashboard: 1,
    editor: 2,
    solution_main: 3,
    solution_dig_deeper: 4
  }
end
