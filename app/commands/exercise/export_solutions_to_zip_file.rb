require 'zip'

class Exercise::ExportSolutionsToZipFile
  include Mandate

  def self.num_submissions = 500

  initialize_with :exercise

  def call
    file_stream = Zip::OutputStream.write_buffer do |zip|
      solutions.each.with_index do |solution, idx|
        submission = solution.iterations.first&.submission
        next unless submission

        # Export the first iteration's files as that iteration won't have
        # had any mentor/analyzer/representer comments applied to them
        submission.files.each do |iteration_file|
          zip.put_next_entry "#{idx}/#{iteration_file.filename}"
          zip.print iteration_file.content.force_encoding("utf-8")
        end

        # Export the other (exercise) files
        submission.exercise_files.each do |filepath, contents|
          zip.put_next_entry "#{idx}/#{filepath}"
          zip.print contents.force_encoding("utf-8")
        end
      end
    end

    file_stream.rewind
    file_stream.sysread
  end

  private
  def solutions
    exercise.solutions.includes(iterations: { submission: :files }).
      where(status: %i[iterated completed published]).
      last(self.class.num_submissions)
  end
end
