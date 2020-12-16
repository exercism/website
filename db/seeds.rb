puts "Creating User iHiD"
iHiD = User.find_by(handle: 'iHiD') || User.create!(
  handle: 'iHiD', 
  email: 'ihid@exercism.io', 
  name: 'Jeremy Walker', 
  password: 'password',
  github_username: 'iHiD',
  bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best."
)
iHiD.confirm
iHiD.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
auth_token = iHiD.auth_tokens.create!

iHiD.create_profile(
  location: "Bree, Middle Earth",
  github: "iHiD",
  twitter: "iHiD",
  linkedin: "iHiD",
  medium: "iHiD",
  website: "https://ihid.info"
)

puts "Creating User erikSchierboom"
erik = User.find_by(handle: 'erikSchierboom') || User.create!(
  handle: 'erikSchierboom', 
  email: 'erik@exercism.io', 
  name: 'Erik Schierboom',
  github_username: 'ErikSchierboom', 
  password: 'password',
  bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best."
)
erik.confirm
erik.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)

puts "Creating User kntsoriano"
karlo = User.find_by(handle: 'kntsoriano') || User.create!(
  handle: 'kntsoriano', 
  email: 'karlo@exercism.io', 
  name: 'Karlo Soriano', 
  password: 'password',
  github_username: 'kntsoriano', 
  bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best."
)
karlo.confirm
karlo.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)

# This is all temporary and horrible while we have a monorepo
repo_url = "https://github.com/exercism/v3"
repo = Git::Repository.new(:v3, repo_url: repo_url)

# This fetches it once before we stub it below
repo.fetch!
repo.send(:rugged_repo)

# Adding this is many OOM faster. It's horrible and temporary
# but useful for now
module Git
  class Repository
    def fetch!
    end
  end
end

tags = [
  [
    "Compiles to:Binary",
    "Compiles to:Bytecode",
    "Compiles to:JavaScript",
  ],
  [
    "Runtime:Android",
    "Runtime:Browser",
    "Runtime:BEAM (Erlang)",
    "Runtime:Common Language Runtime (.NET)",
    "Runtime:iOS",
    "Runtime:JVM (Java)",
    "Runtime:V8 (NodeJS)",
  ],
  [
    "Paradigm:Declarative",
    "Paradigm:Functional",
    "Paradigm:Imperative",
    "Paradigm:Logic",
    "Paradigm:Object-oriented",
    "Paradigm:Procedural",
  ],
  [
    "Typing:Static",
    "Typing:Dynamic",
  ],
  [
    "Family:C-like",
    "Family:Lisp",
    "Family:ML",
    "Family:Java",
    "Family:JavaScript",
    "Family:SASL",
    "Family:sh",
  ],
  [
    "Domain:Cross-platform",
    "Domain:Embedded systems",
    "Domain:Games",
    "Domain:GUIs",
    "Domain:Logic",
    "Domain:Maths",
    "Domain:Mobile",
    "Domain:Scripting",
    "Domain:Web development",
  ]
]

track_slugs = []
tree = repo.send(:fetch_tree, repo.head_commit, "languages/")
tree.each_tree { |obj| track_slugs << obj[:name] }

# Find the first commit in the repo
first_commit = repo.head_commit
Rugged::Walker.walk(repo.send(:rugged_repo),
  show: repo.head_commit.oid,
  sort: Rugged::SORT_DATE | Rugged::SORT_TOPO,
  simplify: true
) do |commit|
  first_commit = commit
end

track_slugs.each do |track_slug|
  puts "Adding Track: #{track_slug}"

  begin
    git_track = Git::Track.new(track_slug, repo.head_commit.oid, repo_url: repo_url)
    track = Track::Create.(
      track_slug, 
      title: git_track.config[:language],
      blurb: git_track.config[:blurb],
      repo_url: repo_url,
      synced_to_git_sha: first_commit.oid,
      # Randomly selects 1-5 tags from different categories
      tags: tags.sample(1 + rand(5)).map {|category|category.sample}
    )
    Git::SyncTrack.(track)
  rescue StandardError => e
    # puts e.message
    # puts e.backtrace
    puts "Error seeding Track #{track_slug}: #{e}"
  end
end

puts ""
puts "To use the CLI locally, run: "
puts "exercism configure -a http://localhost:3020/api/v1 -t #{auth_token.token}"
puts ""

ruby = Track.find_by_slug(:ruby)
UserTrack.create!(user: iHiD, track: ruby)
solution = Solution::Create.(
  iHiD, 
  ruby.concept_exercises.find_by!(slug: "lasagna")
)
submission = Submission.create!(
  solution: solution,
  uuid: SecureRandom.uuid,
  submitted_via: "cli"
)
submission.files.create!(
  filename: "lasagna.rb",
  content: "class Lasagna\nend",
  digest: SecureRandom.uuid
)
Iteration.create!(
  submission: submission,
  solution: solution,
  idx: 1
)

Solution::Publish.(solution, [])

## Create mentoring solutions
UserTrack.create!(user: erik, track: ruby)
solution = Solution::Create.( erik, ruby.concept_exercises.find_by!(slug: "lasagna"))
submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
Iteration.create!( submission: submission, solution: solution, idx: 1)
Solution::MentorRequest.create!(solution: solution, type: :code_review)

## Create mentoring solutions
UserTrack.create!(user: karlo, track: ruby)
solution = Solution::Create.( karlo, ruby.concept_exercises.find_by!(slug: "lasagna"))
submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
Iteration.create!( submission: submission, solution: solution, idx: 1)

submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\n\nend", digest: SecureRandom.uuid)
Iteration.create!( submission: submission, solution: solution, idx: 2)

req = Solution::MentorRequest.create!(solution: solution, type: :code_review)
discussion = Solution::MentorDiscussion.create!(request: req, solution: solution, mentor: iHiD)
p "Discussion: #{discussion.uuid}"
