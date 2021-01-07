module API
  module Submissions
    class FilesController < BaseController
      def index
        submission = Submission.find_by!(uuid: params[:submission_id])

        files = submission.files.map do |file|
          {
            filename: file.filename,
            content: file.content
          }
        end

        render json: { files: files }
      end
    end
  end
end
