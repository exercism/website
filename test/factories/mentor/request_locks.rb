FactoryBot.define do
  factory :mentor_request_lock, class: 'Mentor::RequestLock' do
    request { create :mentor_request }
    locked_until { Time.current }
    locked_by { create :user }
  end
end
