FactoryBot.define do
  factory :submission_file, class: 'Submission::File' do
    submission
    filename { "foobar.rb" }
    digest { SecureRandom.compact_uuid }
    content { "class Foobar\nend" }
  end
end
