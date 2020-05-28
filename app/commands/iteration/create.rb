class Iteration
  class Create
    include Mandate

    def initialize(solution, files, submitted_via)
      @solution = solution
      @files = files
      @submitted_via = submitted_via
      @iteration_uuid = SecureRandom.compact_uuid

      @files.each do |f|
        f[:uuid] = SecureRandom.compact_uuid,
        f[:digest] = Digest::SHA1.hexdigest(f[:content])
      end
    end

    def call
      # This needs to be fast. 
      guard!

      # Kick off the threads to get things uploaded
      # before we do anything with the database.

      # These thread must *not* touch the DB or have any 
      # db models passed to them.
      threads = [
        Thread.new { init_services },
        Thread.new { Iteration::UploadForStorage.(iteration_uuid, files) }
      ]

      iteration = create_iteration!
      update_solution!
      
      # Finally wait for everyting to finish before
      # we return the iteration
      threads.each(&:join)

      # End by returning the new iteration
      iteration
    end

    private
    attr_reader :solution, :files, :iteration_uuid, :submitted_via

    def guard!
      last_iteration = solution.iterations.last
      return unless last_iteration

      prev_files = last_iteration.files.map {|f| "#{f.filename}|#{f.digest}" }
      new_files = files.map {|f| "#{f[:filename]}|#{f[:digest]}" }
      raise DuplicateIterationError if prev_files.sort == new_files.sort
    end

    def init_services
      git_slug = solution.git_slug
      git_sha = solution.git_sha
      track_repo = solution.track.repo
      
      # Let's get it up first, then we'll fan out to
      # all the services we want to run this,
      Iteration::UploadWithExercise.(iteration_uuid, git_slug, git_sha, track_repo, files) 

      [
        Thread.new{Iteration::TestRun::Init.(iteration_uuid, solution.track.slug, solution.exercise.slug) },
        Thread.new{Iteration::Analysis::Init.(iteration_uuid, solution.track.slug, solution.exercise.slug) },
        Thread.new{Iteration::Representation::Init.(iteration_uuid, solution.track.slug, solution.exercise.slug) }
      ].each(&:join)
    end

    def create_iteration!
      solution.iterations.create!(
        uuid: iteration_uuid, 
        submitted_via: submitted_via
      ).tap do |iteration|
        files.each do |file|
          iteration.files.create!(file.slice(:uuid, :filename, :content, :digest))
        end
      end
    end

    def update_solution!
      solution.status = :submitted if solution.pending?
      solution.save!
    end
  end
end
