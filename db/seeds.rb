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
User::AcquiredBadge.create!(user: iHiD, badge: Badge.find_by_slug!(:rookie)) #rubocop:disable Rails/DynamicFindBy
User::AcquiredBadge.create!(user: iHiD, badge: Badge.find_by_slug!(:member)) #rubocop:disable Rails/DynamicFindBy

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

track_slugs = %w[05ab1e ada arm64-assembly ballerina bash c ceylon cfml clojure clojurescript coffeescript common-lisp coq cpp crystal csharp d dart delphi elixir elm emacs-lisp erlang factor forth fortran fsharp gleam gnu-apl go groovy haskell haxe idris io j java javascript julia kotlin lfe lua mips nim nix objective-c ocaml perl5 pharo-smalltalk php plsql pony powershell prolog purescript python r racket raku reasonml ruby rust scala scheme shen sml solidity swift system-verilog tcl typescript vbnet vimscript x86-64-assembly zig]
track_slugs.each do |track_slug|
  next unless track_slug == "ruby" || track_slug == "csharp"

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
      title: git_track.config[:language],
      blurb: git_track.config[:blurb],
      tags: git_track.config[:tags].to_a,
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
Iteration::Create.(solution, submission)

Solution::Publish.(solution, [])

## Create mentoring solutions
UserTrack.create!(user: erik, track: ruby)
solution = Solution::Create.( erik, ruby.concept_exercises.find_by!(slug: "lasagna"))
submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
Iteration.create!( submission: submission, solution: solution, idx: 1)
Solution::MentorRequest.create!(solution: solution, comment_markdown: "I would like to improve the performance of my code")

## Create mentoring solutions
UserTrack.create!(user: karlo, track: ruby)
solution = Solution::Create.( karlo, ruby.concept_exercises.find_by!(slug: "lasagna"))
submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
Iteration.create!( submission: submission, solution: solution, idx: 1)

submission = Submission.create!( solution: solution, uuid: SecureRandom.uuid, submitted_via: "cli")
submission.files.create!( filename: "lasagna.rb", content: "class Lasagna\n\nend", digest: SecureRandom.uuid)
Iteration.create!( submission: submission, solution: solution, idx: 2)

req = Solution::MentorRequest.create!(solution: solution, comment_markdown: "Could you please look at my code?")
discussion = Solution::MentorDiscussion.create!(
  request: req, solution: solution, mentor: iHiD,
  requires_mentor_action_since: Time.current
)
p "Discussion: #{discussion.uuid}"

Mentor::Testimonial.create!(
  mentor: iHiD, student: erik, discussion: discussion, 
  content: "For the first time in my life, someone got my name right the first time round. I’m not really sure what that means, but, I think I’m gonna go and celebrate. Man, I can’t believe this. I can’t believe SleeplessByte got my name right!"
)
