# Create system user
User.find_by_id(1) || User.create!(
  handle: 'exercism-bot',
  email: "#{SecureRandom.uuid}@exercism.io",
  name: 'Exercism Bot',
  github_username: 'exercism-bot',
  password: SecureRandom.uuid,
  bio: "I am the Exercism Bot"
)
User.find_by_id(2) || User.create!(
  handle: 'exercism-ghost',
  email: "#{SecureRandom.uuid}@exercism.io",
  name: 'Exercism Ghost',
  github_username: 'exercism-ghost',
  password: SecureRandom.uuid,
  bio: "I am the Ghost of old users who have left"
)


puts "Creating User iHiD"
iHiD = User.find_by(handle: 'iHiD') || User.create!(
  handle: 'iHiD',
  email: 'ihid@exercism.io',
  name: 'Jeremy Walker',
  password: 'password',
  github_username: 'iHiD',
  bio: "Co-founder of Exercism. I'm an entrepreneur and software developer, and have been running a variety of businesses and non-for-profits for the last decade in the fields of medicine, education and artificial intelligence",
  location: "Bree, Middle Earth",
  pronouns: "He/Him",
  roles: [:admin]
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
)
User::AcquiredBadge.create!(user: iHiD, badge: Badge.find_by_slug!(:rookie)) #rubocop:disable Rails/DynamicFindBy
User::AcquiredBadge.create!(user: iHiD, badge: Badge.find_by_slug!(:member)) #rubocop:disable Rails/DynamicFindBy

puts "Creating User erikSchierboom"
erik = User.find_by(handle: 'erikSchierboom') || User.create!(
  handle: 'erikSchierboom',
  email: 'erik@exercism.io',
  name: 'Erik Schierboom',
  github_username: 'ErikSchierboom',
  password: 'password',
  bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.",
  roles: [:admin]
)
erik.confirm
erik.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
erik.auth_tokens.create!

puts "Creating User kntsoriano"
karlo = User.find_by(handle: 'kntsoriano') || User.create!(
  handle: 'kntsoriano',
  email: 'karlo@exercism.io',
  name: 'Karlo Soriano',
  password: 'password',
  github_username: 'kntsoriano',
  bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.",
  roles: [:admin]
)
karlo.confirm
karlo.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
karlo.auth_tokens.create!

track_slugs = %w[05ab1e ada arm64-assembly ballerina bash c ceylon cfml clojure clojurescript coffeescript common-lisp coq cpp crystal csharp d dart delphi elixir elm emacs-lisp erlang factor forth fortran fsharp gleam gnu-apl go groovy haskell haxe idris io j java javascript julia kotlin lfe lua mips nim nix objective-c ocaml perl5 pharo-smalltalk php plsql pony powershell prolog purescript python r racket raku reasonml ruby rust scala scheme shen sml solidity swift system-verilog tcl typescript vbnet vimscript x86-64-assembly zig]
track_slugs.each do |track_slug|
  next unless %w[ruby csharp prolog].include?(track_slug)

  begin
    puts "Adding Track: #{track_slug}"

    repo_url = "https://github.com/exercism/#{track_slug}"
    repo = Git::Repository.new(repo_url: repo_url)

    # Find the first commit in the repo
    first_commit = repo.head_commit
    Rugged::Walker.walk(repo.send(:rugged_repo),
      show: repo.head_commit.oid,
      sort: Rugged::SORT_DATE | Rugged::SORT_TOPO,
      simplify: true
    ) do |commit|
      first_commit = commit
    end

    git_track = Git::Track.new(repo.head_commit.oid, repo_url: repo_url)
    track = Track::Create.(
      track_slug,
      title: git_track.title,
      blurb: git_track.blurb,
      tags: git_track.tags,
      repo_url: repo_url,
      synced_to_git_sha: first_commit.oid
    )
    Git::SyncTrack.(track)
  rescue StandardError => e
    # puts e.message
    # puts e.backtrace
    puts "Error seeding Track #{track_slug}: #{e.message}"
    puts e.backtrace
  end
end

puts ""
puts "To use the CLI locally, run: "
puts "exercism configure -a http://local.exercism.io:3020/api/v1 -t #{auth_token.token}"
puts ""

ruby = Track.find_by_slug(:ruby)
user_track = UserTrack.create!(user: iHiD, track: ruby)
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
Solution::Publish.(solution, [])

## Create mentoring solutions
UserTrack.create!(user: erik, track: ruby)
Solution::Create.( erik, ruby.practice_exercises.find_by!(slug: "hello-world")).update(completed_at: Time.current)

solution = Solution::Create.( erik, ruby.concept_exercises.find_by!(slug: "lasagna"))
submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
Iteration.create!(uuid: SecureRandom.uuid, submission: submission, solution: solution, idx: 1)
Mentor::Request.create!(solution: solution, comment_markdown: "I would like to improve the performance of my code")

## Create mentoring solutions
UserTrack.create!(user: karlo, track: ruby)
Solution::Create.( karlo, ruby.practice_exercises.find_by!(slug: "hello-world")).update(completed_at: Time.current)

ruby.practice_exercises.limit(10).each do |exercise|
  solution = Solution::Create.( karlo, exercise )
  submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
  submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
  Iteration.create!(uuid: SecureRandom.uuid,  submission: submission, solution: solution, idx: 1)

  submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
  submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\n\nend", digest: SecureRandom.uuid)
  Iteration.create!(uuid: SecureRandom.uuid,  submission: submission, solution: solution, idx: 2)

  req = Mentor::Request.create!(solution: solution, comment_markdown: "Could you please look at my code?")
  discussion = Mentor::Discussion.create!(
    request: req, solution: solution, mentor: iHiD,
    awaiting_mentor_since: Time.current
  )
  req.update(status: :fulfilled)
  p "Discussion: #{discussion.uuid}"

  Mentor::Testimonial.create!(
    mentor: iHiD, student: erik, discussion: discussion,
    content: "For the first time in my life, someone got my name right the first time round. I’m not really sure what that means, but, I think I’m gonna go and celebrate. Man, I can’t believe this. I can’t believe SleeplessByte got my name right!"[0,(20+rand(210))]
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
    karlo,
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


exercises = Exercise.all.sort_by{rand}[0,3]
iHiD.authored_exercises += exercises

exercises.each do |exercise|
  track = exercise.track
  User::ReputationToken::Create.(
    iHiD,
    :exercise_author,
    track: track,
    exercise: exercise
  )
end

exercises = Exercise.all.sort_by{rand}[0,10]
iHiD.contributed_exercises += exercises
exercises.each do |exercise|
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

