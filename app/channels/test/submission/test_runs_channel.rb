module Test
  module Submission
    class TestRunsChannel < ApplicationCable::Channel
      def subscribed
        stream_for submission
      end

      private
      def submission
        @submission ||= ::Submission.find_by(uuid: params[:uuid])
      end
    end
  end
end
