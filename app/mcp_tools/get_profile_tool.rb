class GetProfileTool < MCP::Tool
  tool_name "get_profile"
  title "Get Exercism profile"
  description <<~DESC.squish
    Get the public profile of an Exercism user by their handle. Returns their name, bio, location,
    reputation, top tracks, badges, number of published solutions and external links.
    Only users who have created a public profile can be found.
  DESC
  input_schema(
    properties: {
      handle: { type: "string", description: "The user's Exercism handle, e.g. iHiD" }
    },
    required: ["handle"]
  )
  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(handle:, server_context:) # rubocop:disable Lint/UnusedMethodArgument
    user = User.find_by(handle:)

    # Users without a profile 404 on the website, so they aren't exposed here either.
    unless user&.profile?
      return MCP::Tool::Response.new(
        [{ type: "text", text: "No Exercism profile found for '#{handle}'." }],
        error: true
      )
    end

    MCP::Tool::Response.new([{ type: "text", text: SerializeProfileSummary.(user).to_json }])
  end
end
