# Create system user
User.find_by_id(User::SYSTEM_USER_ID) || User.create!(
  id: User::SYSTEM_USER_ID,
  handle: 'exercism-bot',
  email: "#{SecureRandom.uuid}@exercism.org",
  name: 'Exercism Bot',
  github_username: 'exercism-bot',
  password: SecureRandom.uuid,
  bio: "I am the Exercism Bot"
)

# Create ghost user
User.find_by_id(User::GHOST_USER_ID) || User.create!(
  id: User::GHOST_USER_ID,
  handle: 'exercism-ghost',
  email: "#{SecureRandom.uuid}@exercism.org",
  name: 'Exercism Ghost',
  github_username: 'exercism-ghost',
  password: SecureRandom.uuid,
  bio: "I am the Ghost of old users who have left"
)

puts "Creating User iHiD"
iHiD = User.find_by_id(User::IHID_USER_ID) || User.create!(
  id: User::IHID_USER_ID,
  handle: 'iHiD',
  email: 'ihid@exercism.org',
  name: 'Jeremy Walker',
  password: 'password',
  github_username: 'iHiD',
  bio: "Co-founder of Exercism. I'm an entrepreneur and software developer, and have been running a variety of businesses and non-for-profits for the last decade in the fields of medicine, education and artificial intelligence",
  location: "Bree, Middle Earth",
  pronouns: "He/Him",
  roles: [:admin, :maintainer, :supermentor]
)
iHiD.confirm
iHiD.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
auth_token = iHiD.auth_tokens.create!

iHiD.create_profile(
  github: "iHiD",
  twitter: "iHiD",
  linkedin: "iHiD",
  medium: "iHiD",
  website: "https://ihid.info"
) unless iHiD.profile
User::AcquiredBadge::Create.(iHiD, :member)

puts "Creating User erikSchierboom"
erik = User.find_by(handle: 'erikSchierboom') || User.create!(
  handle: 'erikSchierboom',
  email: 'erik@exercism.org',
  name: 'Erik Schierboom',
  github_username: 'ErikSchierboom',
  password: 'password',
  bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.",
  roles: [:admin, :maintainer, :supermentor]
)
erik.confirm
erik.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
erik.auth_tokens.create!

puts "Creating User dem4ron"
aron = User.find_by(handle: 'dem4ron') || User.create!(
  handle: 'dem4ron',
  email: 'aron.demeter@exercism.org',
  name: 'Aron Demeter',
  password: 'password',
  github_username: 'dem4ron',
  bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.",
  roles: [:admin, :maintainer, :supermentor]
)
aron.confirm
aron.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
aron.auth_tokens.create!

# Create Alice, a maintainer user
puts "Creating User alice"
alice = User.find_by(handle: 'alice') || User.create!(
  handle: 'alice',
  email: 'alice@exercism.org',
  name: 'Alice',
  password: 'password',
  roles: [:maintainer]
)
alice.confirm
alice.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
alice.auth_tokens.create!

# Create Bob, a regular user
puts "Creating User bob"
bob = User.find_by(handle: 'bob') || User.create!(
  handle: 'bob',
  email: 'bob@exercism.org',
  name: 'Bob',
  password: 'password',
  roles: []
)
bob.confirm
bob.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
bob.auth_tokens.create!

track_slugs = %w[05ab1e 8th abap ada arm64-assembly awk babashka ballerina bash c ceylon cfml clojure clojurescript cobol coffeescript common-lisp coq cpp crystal csharp d dart delphi elixir elm emacs-lisp erlang factor forth fortran free-pascal fsharp gleam gnu-apl gnucobol go groovy haskell haxe idris io j java javascript javascript-legacy julia kotlin lfe lua mips nim nix objective-c ocaml perl5 pharo-smalltalk php plsql pony powershell prolog purescript python qsharp r racket raku reasonml red research_experiment_1 ruby rust scala scheme shen sml solidity swift system-verilog tcl typescript unison vbnet vimscript vlang wasm wren x86-64-assembly zig]
track_slugs.each do |track_slug|
  next unless %w[ruby csharp elixir javascript prolog].include?(track_slug)

  begin
    puts "Adding Track: #{track_slug}"
    Track::Create.("https://github.com/exercism/#{track_slug}")
  rescue StandardError => e
    # puts e.message
    # puts e.backtrace
    puts "Error seeding Track #{track_slug}: #{e.message}"
    puts e.backtrace
  end
end

Git::SyncBlog.()
Git::SyncMainDocs.()

puts ""
puts "To use the CLI locally, run: "
puts "exercism configure -a http://local.exercism.io:3020/api/v1 -t #{auth_token.token}"
puts ""

ruby = Track.find_by_slug(:ruby)
user_track = UserTrack.create_or_find_by!(user: iHiD, track: ruby)
solution = Solution::Create.(
  iHiD,
  ruby.practice_exercises.find_by!(slug: "hello-world")
)
submission = Submission.create!(
  solution: solution,
  uuid: SecureRandom.uuid,
  submitted_via: "cli"
)
submission.files.create!(
  filename: "hello_world.rb",
  content: "class HelloWorld\nend",
  digest: SecureRandom.uuid
)
Iteration::Create.(solution, submission)

Solution::Complete.(solution, user_track)
Solution::Publish.(solution, user_track, [])

## Create mentoring solutions
UserTrack.create_or_find_by!(user: erik, track: ruby)
Solution::Create.(erik, ruby.practice_exercises.find_by!(slug: "hello-world")).update(completed_at: Time.current)

solution = Solution::Create.(erik, ruby.concept_exercises.find_by!(slug: "lasagna"))
submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
Iteration.create!(uuid: SecureRandom.uuid, submission: submission, solution: solution, idx: 1)
Mentor::Request.create!(solution: solution, comment_markdown: "I would like to improve the performance of my code")

## Create mentoring solutions
UserTrack.create_or_find_by!(user: aron, track: ruby, practice_mode: true)
Solution::Create.(aron, ruby.practice_exercises.find_by!(slug: "hello-world")).update(completed_at: Time.current)

UserTrack.create_or_find_by!(user: alice, track: ruby, practice_mode: true)

ruby.practice_exercises.limit(10).each do |exercise|
  [iHiD, erik, alice].each do |user|
    solution = Solution::Create.(user, exercise)
    submission = Submission.create!(solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
    submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
    Iteration.create!(uuid: SecureRandom.uuid,  submission: submission, solution: solution, idx: 1)

    submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
    submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\n\nend", digest: SecureRandom.uuid)
    Iteration.create!(uuid: SecureRandom.uuid,  submission: submission, solution: solution, idx: 2)

    Solution::Publish.(solution, UserTrack.for!(user, ruby), 1)
  end

  solution = Solution::Create.(aron, exercise)
  submission = Submission.create!(solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
  submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
  Iteration.create!(uuid: SecureRandom.uuid,  submission: submission, solution: solution, idx: 1)

  submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
  submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\n\nend", digest: SecureRandom.uuid)
  Iteration.create!(uuid: SecureRandom.uuid,  submission: submission, solution: solution, idx: 2)

  req = Mentor::Request.create!(solution: solution, comment_markdown: "Could you please look at my code?")
  discussion = Mentor::Discussion::Create.(iHiD, req, 1, "Nice work!")
  Mentor::Discussion::ReplyByStudent.(
    discussion, solution.iterations.first, "Thanks!"
  )
  Mentor::Discussion::ReplyByMentor.(
    discussion, solution.iterations.first, "No probs!"
  )

  p "Discussion: #{discussion.uuid}"

  Mentor::Testimonial.create!(
    mentor: iHiD, student: erik, discussion: discussion,
    content: "#{exercise.id} For the first time in my life, someone got my name right the first time round. I’m not really sure what that means, but, I think I’m gonna go and celebrate. Man, I can’t believe this. I can’t believe SleeplessByte got my name right!"[0,(20+rand(210))]
  )
end

tracks = Track.all
10.times do |i|
  track = tracks.sample
  User::ReputationToken::Create.(
    iHiD,
    :code_merge,
    repo: track.repo_url,
    pr_node_id: SecureRandom.hex,
    pr_number: i,
    pr_title: "PR for #{track.title} #{i}",
    merged_at: i.weeks.ago.utc,
    level: %i[janitorial reviewal].sample
  )
end

5.times do |i|
  track = tracks.sample
  User::ReputationToken::Create.(
    aron,
    :code_review,
    repo: track.repo_url,
    pr_node_id: SecureRandom.hex,
    pr_number: i + 10,
    pr_title: "PR for #{track.title} #{i + 10}",
    merged_at: i.weeks.ago.utc,
    level: %i[tiny small medium large massive].sample
  )
end

10.times do |i|
  track = tracks.sample
  User::ReputationToken::Create.(
    erik,
    :code_review,
    repo: track.repo_url,
    pr_node_id: SecureRandom.hex,
    pr_number: i + 20,
    pr_title: "PR for #{track.title} #{i + 20}",
    merged_at: i.weeks.ago.utc,
    level: %i[tiny small medium large massive].sample
  )
end

5.times do |i|
  track = tracks.sample
  User::ReputationToken::Create.(
    iHiD,
    :code_review,
    repo: track.repo_url,
    pr_node_id: SecureRandom.hex,
    pr_number: i,
    pr_title: "PR for #{track.title} #{i}",
    merged_at: i.weeks.ago.utc,
    level: %i[tiny small medium large massive].sample
  )
end

5.times do |i|
  track = tracks.sample
  User::ReputationToken::Create.(
    iHiD,
    :code_contribution,
    repo: track.repo_url,
    pr_node_id: SecureRandom.hex,
    pr_number: i,
    pr_title: "PR for #{track.title} #{i}",
    merged_at: i.weeks.ago.utc,
    level: %i[tiny small medium large massive].sample,
    track: track,
    exercise: track.exercises.sample
  )
end


authored_exercises = Exercise.all.excluding(iHiD.authored_exercises).sort_by{rand}[0,3]
iHiD.authored_exercises += authored_exercises

authored_exercises.each do |exercise|
  track = exercise.track
  User::ReputationToken::Create.(
    iHiD,
    :exercise_author,
    track: track,
    exercise: exercise
  )
end

contributed_exercises = Exercise.all.excluding(iHiD.contributed_exercises).sort_by{rand}[0,10]
iHiD.contributed_exercises += contributed_exercises
contributed_exercises.each do |exercise|
  track = exercise.track
  User::ReputationToken::Create.(
    iHiD,
    :exercise_contribution,
    track: track,
    exercise: exercise
  )
end

User::ReputationPeriod::Sweep.()

SiteUpdate.delete_all
Exercise.all.each do |exercise|
  SiteUpdates::NewExerciseUpdate.create!(
    exercise: exercise,
    track: exercise.track,
    published_at: exercise.created_at
  )
end

Concept.all.each do |concept|
  SiteUpdates::NewConceptUpdate.create!(
    track: concept.track,
    published_at: concept.created_at,
    params: {
      concept: concept
    }
  )
end

update = SiteUpdate.where(track: ruby).sorted.first
update.update!(
  author: User.first,
  title: "New exercise for OCaml! 🚀",
  description: "Of course, it is likely enough, my friends,' he said slowly, 'likely enough that we are going to our doom: the last march of the Ents. But if we stayed home and did nothing, doom would find us anyway, sooner or later. That thought has long been growing in our hearts; and that is why we are marching now."
)
update.update(pull_request: Github::PullRequest.first)

User::AcquiredBadge::Create.(iHiD, :rookie)
