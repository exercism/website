class Exercise::ExportSolutionsToZipFile
  include Mandate

  initialize_with :exercise

  def call
    # TODO

    solutions = exercise.solutions.
      includes(iterations: :files).
      where(status: %i[iterated completed published]).
      order('id DESC').
      limit(500)

    dir = Rails.root / "tmp" / "export_solutions_data" / "#{Time.now.to_i}-#{SecureRandom.uuid}"
    FileUtils.mkdir_p(dir)

    solutions.each.with_index do |solution, idx|
      solution_dir = dir / idx.to_s
      FileUtils.mkdir_p(solution_dir)

      solution.latest_iteration.files.each do |iteration_file|
        file_dir = solution_dir / iteration_file.filename.split('/').tap(&:pop).join('/')

        FileUtils.mkdir_p(file_dir) unless Dir.exist?(file_dir)
        File.open(solution_dir / iteration_file.filename, "w+") do |file|
          file << iteration_file.content.force_encoding("utf-8")
        end
      end
    end

    (dir / "archive.zip").tap do |zip_path|
      Directory::ZipRecursively.(dir, zip_path)
    end
  end
end
