FactoryBot.define do
  factory :training_data_code_tags_sample, class: 'TrainingData::CodeTagsSample' do
    track { create :track }
    code { "Hello, World!" }
  end
end
