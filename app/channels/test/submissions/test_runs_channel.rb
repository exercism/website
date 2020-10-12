module Test
  module Submissions
    class TestRunsChannel < ApplicationCable::Channel
      def subscribed
        stream_for submission
      end

      private
      def submission
        @submission ||= Submission.find(params[:id])
      end
    end
  end
end
