FactoryBot.define do
  factory :training_data_code_tags_sample, class: 'TrainingData::CodeTagsSample' do
    track { exercise.track }
    exercise { create :practice_exercise }
    files do
      [
        { filename: 'hello.rb', code: "Hello, World!" }
      ]
    end
  end
end
