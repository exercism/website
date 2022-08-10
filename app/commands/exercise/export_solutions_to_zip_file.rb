require 'zip'

class Exercise::ExportSolutionsToZipFile
  include Mandate

  initialize_with :exercise

  def call
    Zip::File.open(zip_file_path, create: true) do |zip_file|
      solutions.each.with_index do |solution, idx|
        solution.latest_iteration.files.each do |iteration_file|
          zip_file.get_output_stream("#{idx}/#{iteration_file.filename}") do |f|
            f.puts(iteration_file.content.force_encoding("utf-8"))
          end
        end
      end
    end

    zip_file_path
  end

  private
  # We need to memoize this as there is randomness in the file path
  memoize
  def zip_file_path = Rails.root / "tmp" / "export_solutions_data" / "#{Time.now.to_i}-#{SecureRandom.uuid}.zip"

  def solutions
    exercise.solutions.includes(iterations: :files).
      where(status: %i[iterated completed published]).
      last(500)
  end
end
