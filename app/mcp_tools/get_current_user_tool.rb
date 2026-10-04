class GetCurrentUserTool < MCP::Tool
  tool_name "get_current_user"
  title "Get signed-in Exercism user"
  description <<~DESC.squish
    Get the Exercism user you're signed in as: their handle, name and reputation.
    Requires signing in to Exercism.
  DESC
  annotations(
    read_only_hint: true,
    destructive_hint: false,
    idempotent_hint: true,
    open_world_hint: false
  )

  def self.call(server_context:)
    user = server_context[:user]

    MCP::Tool::Response.new([{
      type: "text",
      text: {
        handle: user.handle,
        name: user.name,
        reputation: user.reputation,
        profile_url: user.profile? ? Exercism::Routes.profile_url(user) : nil
      }.to_json
    }])
  end
end
