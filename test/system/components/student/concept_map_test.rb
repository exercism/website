require "application_system_test_case"

module Components
  module Student
    class ConceptMapTest < ApplicationSystemTestCase
      def setup
        super

        # This component uses the API, which requires authentication.
        sign_in!
      end

      # TODO: Add in test cases
      # Question, how is this API used like in `tracks_list_test.rb` is there a reference
      # for the DSL?
    end
  end
end
