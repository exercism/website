FactoryBot.define do
  factory :iteration_file, class: 'Iteration::File' do
    uuid { SecureRandom.compact_uuid }
    iteration
    filename { "foobar.rb" }
    digest { SecureRandom.compact_uuid }
  end
end
