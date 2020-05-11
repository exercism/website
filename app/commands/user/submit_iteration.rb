class User
  class SubmitIteration
    include Mandate
    class DuplicateIterationError < RuntimeError; end
    class TooManyIterationsError < RuntimeError; end

    def initialize(solution, files)
      @solution = solution
      @files = files
      @iteration_uuid = SecureRandom.compact_uuid

      @files.each do |f|
        f[:uuid] = SecureRandom.compact_uuid,
        f[:digest] = digest(f[:content])
      end
    end

    def call
      # Kick off the threads to get things uploaded
      # before we do anything with the database.
      # We even want to do this before guarding. A few
      # extra files in s3 isn't a worry.

      # These thread must *not* touch the DB or have any 
      # db models passed to them.
      threads = []

      git_slug = solution.git_slug
      git_sha = solution.git_sha
      track_repo = solution.track.repo
      threads << Thread.new { Iteration::UploadWithExercise.(iteration_uuid, git_slug, git_sha, track_repo, files) }
      threads << Thread.new { Iteration::UploadForStorage.(iteration_uuid, files) }

      guard!
      iteration = create_iteration!
      update_solution!
      
      # Finally wait for everyting to finish before
      # we return the iteration
      threads.each(&:join)

      # End by returning the new iteration
      iteration
    end

    private
    attr_reader :solution, :files, :iteration_uuid

    def guard!
      last_iteration = solution.iterations.last
      return unless last_iteration

      prev_files = last_iteration.files.map {|f| "#{f.filename}|#{f.digest}" }
      new_files = files.map {|f| "#{f[:filename]}|#{f[:digest]}" }
      raise DuplicateIterationError if prev_files.sort == new_files.sort
    end

    def create_iteration!
      solution.iterations.create!(uuid: iteration_uuid).tap do |iteration|
        files.each do |file|
          iteration.files.create!(file.slice(:uuid, :filename, :content, :digest))
        end
      end
    end

    def update_solution!
      solution.status = :submitted if solution.pending?
      solution.save!
    end

    def digest(content)
      Digest::MD5.new.tap {|md5|
        md5.update(content)
      }.hexdigest
    end
  end
end
