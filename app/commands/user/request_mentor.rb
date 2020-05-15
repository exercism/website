class User
  class RequestMentor
    class NotEnoughCreditsError < RuntimeError; end
    class AlreadyRequestedError < RuntimeError
      attr_reader :request
      def initialize(request)
        @request = request
      end
    end

    include Mandate

    initialize_with :solution, :bounty, :type, :comment

    def call
      create_request
    rescue AlreadyRequestedError => e
      e.request
    end

    private
    def create_request
      request = Solution::MentorRequest.new(
        solution: solution,
        type: type, 
        bounty: bounty,
        comment: comment
      )

      ActiveRecord::Base.transaction do
        # Keep this as a local variable for locking
        user = solution.user
        
        solution.lock!
        user.lock!

        # Guard once locked
        raise NotEnoughCreditsError if user.credits < bounty
        
        # Check there's not an existing request. By locking the user before we do this
        # we should be safe that we don't get duplicates here. I'd like a unique index
        # but that would involve schema change as we allow multiple fulfilled records.
        existing_request = solution.mentor_requests.pending.first
        raise AlreadyRequestedError.new(existing_request) if existing_request

        request.save!
      end

      request
    end
  end
end
