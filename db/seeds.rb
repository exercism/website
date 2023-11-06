# Create system user
User.find_by_id(User::SYSTEM_USER_ID) || User.create!(
  id: User::SYSTEM_USER_ID,
  handle: 'exercism-bot',
  email: "#{SecureRandom.uuid}@exercism.org",
  name: 'Exercism Bot',
  password: SecureRandom.uuid
).tap do |u|
  u.update(
    github_username: 'exercism-bot',
    bio: "I am the Exercism Bot"
  )
end

# Create ghost user
User.find_by_id(User::GHOST_USER_ID) || User.create!(
  id: User::GHOST_USER_ID,
  handle: 'exercism-ghost',
  email: "#{SecureRandom.uuid}@exercism.org",
  name: 'Exercism Ghost',
  password: SecureRandom.uuid
).tap do |u|
  u.update(
    github_username: 'exercism-ghost',
    bio: "I am the Ghost of old users who have left"
  )
end

puts "Creating User iHiD"
iHiD = User.find_by_id(User::IHID_USER_ID) || User.create!(
  id: User::IHID_USER_ID,
  handle: 'iHiD',
  email: 'ihid@exercism.org',
  name: 'Jeremy Walker',
  password: 'password',
  location: "Bree, Middle Earth",
  pronouns: "He/Him"
).tap do |u|
  u.update(
    github_username: 'iHiD',
    bio: "Co-founder of Exercism. I'm an entrepreneur and software developer, and have been running a variety of businesses and non-for-profits for the last decade in the fields of medicine, education and artificial intelligence",
    roles: %i[admin maintainer supermentor]
  )
end

iHiD.confirm
iHiD.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
auth_token = iHiD.auth_tokens.create!

unless iHiD.profile
  iHiD.create_profile(
    github: "iHiD",
    twitter: "iHiD",
    linkedin: "iHiD",
    medium: "iHiD",
    website: "https://ihid.info"
  )
end
User::AcquiredBadge::Create.(iHiD, :member)

puts "Creating User erikSchierboom"
erik = User.find_by(handle: 'erikSchierboom') || User.create!(
  handle: 'erikSchierboom',
  email: 'erik@exercism.org',
  name: 'Erik Schierboom',
  password: 'password'
).tap do |u|
  u.update(
    github_username: 'ErikSchierboom',
    bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.",
    roles: %i[admin maintainer supermentor]
  )
end

erik.confirm
erik.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
erik.auth_tokens.create!

puts "Creating User dem4ron"
aron = User.find_by(handle: 'dem4ron') || User.create!(
  handle: 'dem4ron',
  email: 'aron.demeter@exercism.org',
  name: 'Aron Demeter',
  password: 'password'
).tap do |u|
  u.update(
    github_username: 'dem4ron',
    bio: "I am a developer with a passion for learning new languages. I love programming. I've done all the languages. I like the good languages the best.",
    roles: %i[admin maintainer supermentor]
  )
end

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
).tap do |u|
  u.update(
  roles: [:maintainer]
  )
end


alice.confirm
alice.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
alice.auth_tokens.create!

# Create Bob, a regular user
puts "Creating User bob"
bob = User.find_by(handle: 'bob') || User.create!(
  handle: 'bob',
  email: 'bob@exercism.org',
  name: 'Bob',
  password: 'password'
)
bob.confirm
bob.update!(accepted_privacy_policy_at: Time.current, accepted_terms_at: Time.current)
bob.auth_tokens.create!

track_slugs = %w[05ab1e 8th abap ada arm64-assembly awk babashka ballerina bash c ceylon cfml clojure clojurescript cobol coffeescript
                 common-lisp coq cpp crystal csharp d dart delphi elixir elm emacs-lisp erlang factor forth fortran free-pascal fsharp gleam gnu-apl gnucobol go groovy haskell haxe idris io j java javascript javascript-legacy julia kotlin lfe lua mips nim nix objective-c ocaml perl5 pharo-smalltalk php plsql pony powershell prolog purescript python qsharp r racket raku reasonml red research_experiment_1 ruby rust scala scheme shen sml solidity swift system-verilog tcl typescript unison vbnet vimscript vlang wasm wren x86-64-assembly zig]
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
  solution:,
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
submission = Submission.create!(solution:, uuid: SecureRandom.uuid, submitted_via: "cli")
submission.files.create!(filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
Iteration.create!(uuid: SecureRandom.uuid, submission:, solution:, idx: 1)
Mentor::Request.create!(solution:, comment_markdown: "I would like to improve the performance of my code")

## Create mentoring solutions
UserTrack.create_or_find_by!(user: aron, track: ruby, practice_mode: true)
Solution::Create.(aron, ruby.practice_exercises.find_by!(slug: "hello-world")).update(completed_at: Time.current)

UserTrack.create_or_find_by!(user: alice, track: ruby, practice_mode: true)

ruby.practice_exercises.limit(10).each do |exercise|
  [iHiD, erik, alice].each do |user|
    solution = Solution::Create.(user, exercise)
    submission = Submission.create!(solution:, uuid: SecureRandom.uuid, submitted_via: "cli")
    submission.files.create!(filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
    Iteration.create!(uuid: SecureRandom.uuid, submission:, solution:, idx: 1)

    submission = Submission.create!(solution:, uuid: SecureRandom.uuid, submitted_via: "cli")
    submission.files.create!(filename: "lasagna.rb", content: "class Lasagna\n\nend", digest: SecureRandom.uuid)
    Iteration.create!(uuid: SecureRandom.uuid, submission:, solution:, idx: 2)

    Solution::Publish.(solution, UserTrack.for!(user, ruby), 1)
  end

  solution = Solution::Create.(aron, exercise)
  submission = Submission.create!(solution:, uuid: SecureRandom.uuid, submitted_via: "cli")
  submission.files.create!(filename: "lasagna.rb", content: "class Lasagna\nend", digest: SecureRandom.uuid)
  Iteration.create!(uuid: SecureRandom.uuid, submission:, solution:, idx: 1)

  submission = Submission.create!(solution:, uuid: SecureRandom.uuid, submitted_via: "cli")
  submission.files.create!(filename: "lasagna.rb", content: "class Lasagna\n\nend", digest: SecureRandom.uuid)
  Iteration.create!(uuid: SecureRandom.uuid, submission:, solution:, idx: 2)

  req = Mentor::Request.create!(solution:, comment_markdown: "Could you please look at my code?")
  discussion = Mentor::Discussion::Create.(iHiD, req, 1, "Nice work!")
  Mentor::Discussion::ReplyByStudent.(
    discussion, solution.iterations.first, "Thanks!"
  )
  Mentor::Discussion::ReplyByMentor.(
    discussion, solution.iterations.first, "No probs!"
  )

  p "Discussion: #{discussion.uuid}"

  Mentor::Testimonial.create!(
    mentor: iHiD, student: erik, discussion:,
    content: "#{exercise.id} For the first time in my life, someone got my name right the first time round. I’m not really sure what that means, but, I think I’m gonna go and celebrate. Man, I can’t believe this. I can’t believe SleeplessByte got my name right!"[0, rand(20..229)]
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
    track:,
    exercise: track.exercises.sample
  )
end

authored_exercises = Exercise.all.excluding(iHiD.authored_exercises).sort_by { rand }[0, 3]
iHiD.authored_exercises += authored_exercises

authored_exercises.each do |exercise|
  track = exercise.track
  User::ReputationToken::Create.(
    iHiD,
    :exercise_author,
    track:,
    exercise:
  )
end

contributed_exercises = Exercise.all.excluding(iHiD.contributed_exercises).sort_by { rand }[0, 10]
iHiD.contributed_exercises += contributed_exercises
contributed_exercises.each do |exercise|
  track = exercise.track
  User::ReputationToken::Create.(
    iHiD,
    :exercise_contribution,
    track:,
    exercise:
  )
end

User::ReputationPeriod::Sweep.()

SiteUpdate.delete_all
Exercise.all.each do |exercise|
  SiteUpdates::NewExerciseUpdate.create!(
    exercise:,
    track: exercise.track,
    published_at: exercise.created_at
  )
end

Concept.all.each do |concept|
  SiteUpdates::NewConceptUpdate.create!(
    track: concept.track,
    published_at: concept.created_at,
    params: {
      concept:
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

# Clean up
Partner::Advert.destroy_all
Partner::Perk.destroy_all
Partner.destroy_all

packt = Partner.create!(
  name: "Packt Publishing",
  slug: :packt,
  website_url: "https://www.packtpub.com",
  headline: "Access the most comprehensive eBook library in Tech",
  description_markdown: <<~MARKDOWN,
    - Get unlimited access to 6,500+ expert-authored eBooks and video courses covering every tech area you can think of
    - Master the latest advancements before anyone else with our exclusive early access program (heaps of new content added every month)
    - Solve problems as you work with our advanced search and reference features

    ### A Packt Subscription will help you...
    - **Save time and stay focused on work:** Packt’s advanced search helps you get exactly what you need from our expansive library of over 7500+ books and videos.
    - **Stay ahead of the curve:** Be first on new and emerging tech with early access to unpublished books and 50 new titles every month.
    - **Save money and get perks:** Not only is a Packt subscription the best value for money tech library in pure content terms, but you can also earn free DRM-free eBook downloads and other discounts.
    - **Advance your knowledge in tech from the experts:** Our books are written by developers, for developers – we unlock expert knowledge that you won't find anywhere else online.
    - **Read whatever, wherever, whenever:** You can access our library on any device, and even read offline with our mobile app.
    - **Learn your way:** Manage your learning with customisable playlists, notes in books, and personalised recommendations.
  MARKDOWN

  support_markdown: <<~MARKDOWN
    Packt has supported Exercism since 2022, generously donating over $150k to support free education equal access to opportunity.
  MARKDOWN
)
packt.light_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'packt.svg')), filename: "packt.svg")
packt.dark_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'packt.svg')), filename: "packt.svg")

configcat = Partner.create!(
  name: "ConfigCat",
  slug: :configcat,
  website_url: 'https://configcat.com',
  description_markdown: <<~MARKDOWN
    ConfigCat is a feature flag and remote configuration service that allows developers to quickly and easily control the functionality of their applications. With ConfigCat, you can turn features on and off, alter their configurations, and roll out updates gradually to specific users or groups.  Targeting is supported through attributes, percentage-based rollouts, and segmentation, allowing you to tailor the experience for your users. ConfigCat is available for all major programming languages and frameworks and can be accessed as a SaaS or self-hosted service.

    In addition to its powerful feature flag capabilities, ConfigCat also offers a range of benefits for developers and teams. With unlimited team size, you can collaborate with as many team members as you need without worrying about limitations or additional costs. Our team is dedicated to providing exceptional support, so you can always count on us to help you troubleshoot any issues or answer any questions you may have.

    ### Cross-platform feature flag service

    - Turn your features ON/OFF using ConfigCat's Dashboard even after your code is deployed.
    - ConfigCat lets you target user segments based on region, email, subscription or any other custom user attribute. We support % rollouts, A/B testing and variations.
    - ConfigCat is a hosted service for feature flag and configuration management. It lets you decouple feature releases from code deployments.
    - We provide open source SDKs to support easy integration with your Mobile, Desktop application, Website or any Backend system.

    ConfigCat supports over 20 platforms and also has dozens of integrations including GitHub, GitLab, DataDog, Jira and Slack.
  MARKDOWN
)
configcat.light_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'configcat-light.svg')),
  filename: "configcat.svg")
configcat.dark_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'configcat-dark.svg')),
  filename: "configcat.svg")

codecapsules = Partner.create!(
  name: "Code Capsules",
  slug: :code_capsules,
  website_url: 'https://codecapsules.io/',
  headline: "The simplest way to deploy your code.",
  description_markdown: <<~MARKDOWN,
    Code Capsules is a platform-as-a-service geared towards easing the pain of MEAN dev teams.

    They offer a full-scope development environment that allows MEAN developers to focus on building, deploying and scaling their apps.

    With Code Capsules, there’s no need for a host of software solutions like Heroku, Netlify and Atlas. You bring your MEAN stack, they take care of the underlying architecture.

    Code Capsules is the easy, quick and secure way to get your app running, and running smoothly.

    Because their pricing is not based on per-seat billing, Code Capsules is an affordable solution for MEAN teams, whether it’s a two-man show or a behemoth of a dev house
  MARKDOWN
  support_markdown: <<~MARKDOWN
    In 2023 Code Capsules became Exercism's first ever end-to-end advert/marketing sponsor partner.
  MARKDOWN
)

codecapsules.light_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'code-capsules-light.svg')),
  filename: "code-capsules.svg")
codecapsules.dark_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'code-capsules-dark.svg')),
  filename: "code-capsules.svg")

kaido = Partner.create!(
  name: "Kaido",
  slug: :kaido,
  website_url: 'https://kaido.org/challenge',
  description_markdown: <<-MARKDOWN
  MARKDOWN
)
kaido.light_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'kaido-light.svg')), filename: "kaido.svg")
kaido.dark_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'kaido-dark.svg')), filename: "kaido.svg")

stoplight = Partner.create!(
  name: "Stoplight",
  slug: :stoplight,
  website_url: 'https://stoplight.io',
  headline: "Design, document, and build APIs faster.",
  description_markdown: <<~MARKDOWN
    Stoplight is a global API technology company offering a SaaS platform for high-quality API development at any scale. As an industry leader with patented technology in API design, Stoplight’s solution brings together editing, documentation, and governance into one powerful API enablement platform.#{' '}

    Stoplight's company mission is to power an intuitive and frictionless experience to scale business with effective API programs through API innovation, collaboration, and delightful developer experiences. Stoplight values being an owner, building together, practicing mindfulness, and delighting customers.

    Stoplight is remote-first and based in the United States.#{' '}
  MARKDOWN
)
stoplight.light_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'stoplight-light.svg')),
  filename: "stoplight.svg")
stoplight.dark_logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'stoplight-dark.svg')),
  filename: "stoplight.svg")

packt.perks.create!(
  status: :active,
  preview_text: "Packt is the online library and learning platform for professional developers. Learn Python, JavaScript, Angular and more with eBooks, videos and courses.",

  general_url: "https://www.packtpub.com/checkout/subscription/packt-exercism-25-7h3kf",
  general_offer_summary_markdown: "Get **25% off a Packt annual membership** with your Exercism account.",
  general_button_text: "Claim 25% discount",

  general_offer_details: <<~TEXT,
    Packt are offering 25% off their annual subscription for all users. Exercism Premium users and Insiders get a further 25% off too.
    Simply click the button below to checkout with the discount already applied.
  TEXT

  insiders_url: "https://www.packtpub.com/checkout/subscription/packt-exercism-7h3kf",
  insiders_offer_summary_markdown: "Get **50% off a Packt annual membership** with your Exercism account.",
  insiders_button_text: "Claim 50% discount",

  insiders_offer_details: <<~TEXT
    Packt are offering 50% off their annual subscription for all Exercism Premium users and Exercism Insiders.
    Simply click the button below to checkout with the discount already applied.
  TEXT
)

configcat.perks.create!(
  status: :active,
  preview_text: "ConfigCat is a developer-centric feature flag service with unlimited team size, awesome support, and a forever free plan.",

  general_url: "https://app.configcat.com/auth/signup",
  general_offer_summary_markdown: "Get ConfigCat Pro **entirely free** for one year and save >$1,000!",
  general_offer_details: "Get 100% off of the ConfigCat Pro plan for the first year and unlock the full power of feature flagging and configuration management. Simply use the provided coupon code during checkout",
  general_button_text: "Claim 100% discount",
  general_voucher_code: "CONFIGCAT-LOVES-EXERCISM"
)

codecapsules.perks.create!(
  status: :active,
  preview_text: "The PaaS that offers you a simple way to deploy your code. Build, push, deploy and scale your apps quickly, easily, and securely.",
  general_url: "https://codecapsules.io/auth/registration",
  general_offer_summary_markdown: "Get a $5 credit (worth 1 month of free hosting) with your Exercism account.",
  general_offer_details: "Deploy a frontend or backend app free for a month with a $5 credit. Simply use the voucher code below at checkout.",
  general_button_text: "Claim $5 credit",
  general_voucher_code: "PENDING",

  insiders_url: "https://codecapsules.io/auth/registration",
  insiders_offer_summary_markdown: "Get a $10 credit (worth 2 months of free hosting) with your Premium account.",
  insiders_offer_details: "Deploy a frontend or backend app free for two months with a $10 credit. Simply use the voucher code below at checkout.",
  insiders_button_text: "Claim $10 credit",
  insiders_voucher_code: "PENDING"
)

stoplight.perks.create!(
  status: :active,
  preview_text: "Stoplight offers a SaaS platform for high-quality, standards-based APIs, bringing together design, editing, documentation & governance at scale.",

  general_url: "https://stoplight.io/welcome",
  general_offer_summary_markdown: "Get **30% off any Stoplight self-serve plan** with your Exercism account.",
  general_offer_details: "Design, document, and build APIs faster with 30% off any Stoplight self-serve plan (annual or monthly). Use the code below at checkout.",
  general_button_text: "Claim 30% discount",
  general_voucher_code: "NotMyEx30"
)

kaido.perks.create!(
  status: :active,
  preview_text: "Kaido is the leading wellbeing challenge platform, supporting teams' mental and physical health and helping them have fun together.",

  general_url: "https://kaido.org/challenge",
  general_offer_summary_markdown: "Get 20% off your first team Kaido Challenge with your Exercism account.",
  general_offer_details: "Get 20% off your first Kaido Challenge with your Exercism account.",
  general_button_text: "Claim 20% discount"
)

#     advert = Partner.first.adverts.create!(
#       url: "#",
#       base_text: "Cross-platform, developer-centric feature flags.",
#       emphasised_text: "Get 20% off through Exercism Perks."
#     )
#     advert.logo.attach(io: File.open(Rails.root.join('app', 'images', 'partners', 'config-cat.png')), filename: "config-cat.png")

Track::Trophies::Reseed.create!

Solution.published.each do |solution|
  next if solution.iterations.last.files.map(&:content).all?(&:empty?)

  TrainingData::CodeTagsSample.create!(
    solution: solution,
    files: solution.iterations.last.files.map { |file|
      { filename: file.filename, code: file.content }
    }
  )
end

