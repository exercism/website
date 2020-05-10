FactoryBot.define do
  factory :iteration_file do
    iteration
    filename { "foobar.rb" }
    contents { "foobar contents" }
  end
end
