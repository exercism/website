FactoryBot.define do
  factory :iteration_file, class: 'Iteration::File' do
    iteration
    filename { "foobar.rb" }
    digest { SecureRandom.compact_uuid }
  end
end
