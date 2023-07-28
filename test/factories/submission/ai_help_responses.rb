FactoryBot.define do
  factory :submission_ai_help_record, class: 'Submission::AIHelpRecord' do
    submission { create :submission }
    advice_markdown { "you're great" }
    source { "chatgpt 4.0" }
  end
end
