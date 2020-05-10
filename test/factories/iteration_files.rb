FactoryBot.define do
  factory :iteration_file do
    iteration
    filename { "foobar.rb" }
    content { "foobar content" }
  end
end
