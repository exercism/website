FactoryBot.define do
  factory :iteration_file do
    uuid { SecureRandom.compact_uuid }
    iteration
    filename { "foobar.rb" }
    content { "foobar content" }
    digest { SecureRandom.compact_uuid }
  end
end
