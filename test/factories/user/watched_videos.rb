FactoryBot.define do
  factory :user_watched_video, class: 'User::WatchedVideo' do
    user
    video_provider { :youtube }
    video_id { SecureRandom.uuid }
  end
end
