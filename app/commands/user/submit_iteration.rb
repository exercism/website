class User
  class SubmitIteration
    include Mandate
    class DuplicateIterationError < RuntimeError; end

    initialize_with :solution, :files

    def call
      guard!

      iteration = solution.iterations.create!
      files.each do |file|
        iteration.files.create!(file)
      end
      iteration
    end

    private
    def guard!
      guard_duplicate!
    end

    def guard_duplicate!
      last_iteration = solution.iterations.last
      return unless last_iteration

      prev_files = last_iteration.files.map {|f| "#{f.filename}|#{f.digest}" }
      new_files = files.map {|f| "#{f[:filename]}|#{IterationFile.generate_digest(f[:content])}" }
      raise DuplicateIterationError if prev_files.sort == new_files.sort
    end
  end
end
