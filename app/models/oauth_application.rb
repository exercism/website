# Doorkeeper's application model, extended for MCP clients.
#
# MCP clients such as Claude identify themselves with a Client ID Metadata
# Document (CIMD): their client_id is an https URL serving JSON that lists
# their name and redirect URIs. Rather than anyone registering them, we
# fetch that document and keep an application for it, keyed by the URL.
class OauthApplication < Doorkeeper::Application
  def self.by_uid(uid)
    return super unless uid.to_s.start_with?("https://")

    OauthApplication::RetrieveFromMetadataDocument.(uid.to_s)
  end

  def mcp_client? = uid.start_with?("https://")

  # Shown on the consent screen. The document's client_name is chosen by the
  # client, so the host of the URL is what tells the user who is asking.
  def display_name = mcp_client? ? URI(uid).host : name
end
