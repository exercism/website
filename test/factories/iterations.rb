FactoryBot.define do
  factory :iteration do
    solution { submission.solution }
    submission
    idx { 0 }
  end
end
