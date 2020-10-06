FactoryBot.define do
  factory :submission_file, class: 'Submission::File' do
    submission
    filename { "foobar.rb" }
    digest { SecureRandom.compact_uuid }
  end
end
