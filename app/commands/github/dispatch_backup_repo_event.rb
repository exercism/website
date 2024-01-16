class Github::DispatchBackupRepoEvent
  include Mandate

  initialize_with :repo

  def call = Github::DispatchEvent.(REPO, EVENT_TYPE, client_payload)

  private
  def client_payload = { repo: }

  REPO = 'backup'.freeze
  EVENT_TYPE = 'backup_repo'.freeze
  private_constant :REPO, :EVENT_TYPE
end
