module V2ETL
  module DataProcessors
    class ProcessSubmissions
      include Mandate

      def call
        re_1 = /\\+/
        re_3 = /^\//

        Track.find_each do |track|
          puts "Processing #{track.slug} files"
          files_to_upsert = []
          re_2 = /.*?\/(#{Regexp.escape(track.slug)})\/[^\/]+\/(.+)/

          Submission::File.joins(submission: :exercise).where('exercises.track_id': track.id).each do |file|
            sanitized_filename = file.filename

            # Replace one or more consecutive backslashes with one slash
            sanitized_filename.gsub!(re_1, '/')

            # Strip off everything before and including the <track>/<exercise> part of the path
            sanitized_filename.gsub!(re_2, '\2') if sanitized_filename.include?(track.slug)

            # Remove leading slash
            sanitized_filename.gsub!(re_3, '')

            next if file.filename == sanitized_filename

            files_to_upsert << file.attributes.symbolize_keys.merge(filename: sanitized_filename)
          end

          if files_to_upsert.present?
            puts "upserting #{files_to_upsert.size}"
            Submission::File.upsert_all(files_to_upsert)
          end
        end
      end
    end
  end
end
