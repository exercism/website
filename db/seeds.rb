
# This is all temporary and horrible while we have a monorepo
repo_url = "https://github.com/exercism/v3"
repo = Git::Repository.new(:v3, repo_url: repo_url)

# This updates it once before we stub it below
repo.update!
repo.send(:rugged_repo)

# Adding this is many OOM faster. It's horrible and temporary
# but useful for now
module Git
  class Repository
    def rugged_repo
      Rugged::Repository.new(repo_dir)
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

track_slugs.each do |track_slug|
  if Track.find_by(slug: track_slug)
    puts "Track already added: #{track_slug}"
    next
  end

  begin
    git_track = Git::Track.new(track_slug, repo.head_commit.oid, repo_url: repo_url)

    puts "Adding Track: #{track_slug}"
    track = Track.create!(
      slug: track_slug, 
      title: git_track.config[:language],
      blurb: git_track.config[:blurb],
      repo_url: repo_url,
      synced_to_git_sha: repo.head_commit.oid,

      # Randomly selects 1-5 tags from different categories
      tags: tags.sample(1 + rand(5)).map {|category|category.sample}
    )

    #track.update(title: track.repo.config[:language])
    git_track.config[:exercises][:concept].each do |exercise_config|
      ce = ConceptExercise.create!(
        track: track,
        uuid: (exercise_config[:uuid].presence || SecureRandom.compact_uuid),
        slug: exercise_config[:slug],
        title: exercise_config[:slug].titleize,
        git_sha: repo.head_commit.oid,
        synced_to_git_sha: repo.head_commit.oid,
      )
      
      exercise_config[:prerequisites].each do |slug|
        ce.prerequisites << Track::Concept.find_or_create_by!(slug: slug,  track: track) do |c|
          concept_config = git_track.config[:concepts].find { |e| e[:slug] == slug }
          next unless concept_config

          c.uuid = concept_config[:uuid]
          c.name = concept_config[:name]
          c.blurb = concept_config[:blurb].to_s
          c.synced_to_git_sha = git_track.head_sha
        end
      end
      
      exercise_config[:concepts].each do |slug|
        ce.taught_concepts << Track::Concept.find_or_create_by!(slug: slug, track: track) do |c|
          concept_config = git_track.config[:concepts].find { |e| e[:slug] == slug }
          next unless concept_config

          c.uuid = concept_config[:uuid]
          c.name = concept_config[:name]
          c.blurb = concept_config[:blurb].to_s
          c.synced_to_git_sha = git_track.head_sha
        end
      end
    end
  rescue StandardError => e
    # puts e.message
    # puts e.backtrace
    puts "Error seeding Track #{track_slug}: #{e}"
  end
end


puts "Creating User iHiD"
user = User.create!(handle: 'iHiD') unless User.find_by(handle: 'iHiD')
UserTrack.create!(user: user, track: Track.find_by_slug!("ruby"))
auth_token = user.auth_tokens.create!

puts ""
puts "To use the CLI locally, run: "
puts "exercism configure -a http://localhost:3020/api/v1 -t #{auth_token.token}"
puts ""

=begin
concept_exercise = ConceptExercise.create!(track: track, uuid: SecureRandom.uuid, slug: "numbers", prerequisites: [], title: "numbers")
practice_exercise = PracticeExercise.create!(track: track, uuid: SecureRandom.uuid, slug: "bob", prerequisites: [], title: "bob")
concept_solution = ConceptSolution.create!(exercise: concept_exercise, user: user, uuid: SecureRandom.uuid)
practice_solution = PracticeSolution.create!(exercise: practice_exercise, user: user, uuid: SecureRandom.uuid)

Submission.create!(
  solution: concept_solution,
  uuid: SecureRandom.uuid,
  submitted_via: "cli"
)
=end
