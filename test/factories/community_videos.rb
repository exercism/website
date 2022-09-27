FactoryBot.define do
  factory :community_video do
    submitted_by { create :user }
  end
end
