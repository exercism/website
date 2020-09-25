module ViewComponents
  module Mentoring
    class Inbox < ViewComponent
      initialize_with :conversations_request, :tracks_request

      def to_s
        react_component(
          "mentoring-inbox",
          {
            conversations_request: conversations_request,
            tracks_request: tracks_request,
            sort_options: SORT_OPTIONS
          }
        )
      end

      SORT_OPTIONS = [
        { value: 'recent', label: 'Sort by Most Recent' },
        { value: 'exercise', label: 'Sort by Exercise' },
        { value: 'student', label: 'Sort by Student' }
      ].freeze
      private_constant :SORT_OPTIONS
    end
  end
end
