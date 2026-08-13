module ReactComponents
  module UserIdentity
    # Reputation changes continuously and independently of any page it appears
    # on, so it is fetched client-side from /api/v2/users/:handle.json rather
    # than being baked into cacheable HTML. See PERF_DEBUGGING.md.
    class Reputation < ReactComponent
      initialize_with :handle, track: nil, size: nil, type: :common, plain: false

      def to_s
        super(
          "user-identity-reputation",
          {
            handle:,
            track: track&.to_s,
            size:,
            type:,
            plain:
          },
          fitted: true,
          style: "display: inline-flex; vertical-align: middle"
        )
      end
    end
  end
end
