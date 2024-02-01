class User::WatchedVideo < ApplicationRecord
  belongs_to :user
  enum video_provider: { youtube: 1, vimeo: 2 }
end
