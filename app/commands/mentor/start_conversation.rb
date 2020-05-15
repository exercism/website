module Mentor
  class StartConversation
    include Mandate

    initialize_with :mentor, :request

    def call
      ActiveRecord::Base.transaction do
        request.fulfilled!

        Solution::MentorConversation.create!(
          mentor: mentor,
          request: request
        )
      end
    end
  end
end

