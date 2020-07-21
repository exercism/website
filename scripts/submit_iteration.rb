# Run with:
# bundle exec rails r scripts/submit_iteration.rb

user = User.create!(handle: SecureRandom.uuid)

puts "Creating Track..."

ruby = Track.find_by(slug: :ruby) ||
       Track.create!(slug: 'ruby', title: 'Ruby', repo_url: "http://github.com/exercism/ruby")

puts "Creating Exercise..."

two_fer = ConceptExercise.find_by(track: ruby, slug: "two-fer") ||
          ConceptExercise.create!(track: ruby, uuid: SecureRandom.uuid, slug: "two-fer", prerequisites: [], title: "Two Fer")

puts "Creating Solution..."

solution = ConceptSolution.create!(
  uuid: SecureRandom.uuid,
  user: user,
  exercise: two_fer
)

puts "Creating Iteration..."

Iteration::Create.(
  solution,
  [
    {
      filename: "two_fer.rb",
      content: %q{
class TwoFer
  def two_fer(name=nil)
    "One for #{name}, one for me"
  end
end
      }.strip
    }
  ],
  submitted_via: "script"
)
