FactoryBot.define do
  factory :mentor_student_relationship, class: 'Mentor::StudentRelationship' do
    mentor { create :user }
    student { create :user }
  end
end
