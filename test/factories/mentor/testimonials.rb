FactoryBot.define do
  factory :mentor_testimonial, class: 'Mentor::Testimonial' do
    mentor { create :user }
    student { create :user }
    discussion { create :mentor_discussion }
    content { "What an absolute legend!!" }
  end
end
