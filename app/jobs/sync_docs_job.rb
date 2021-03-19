class SyncDocsJob < ApplicationJob
  queue_as :default

  def perform
    Git::SyncMainDocs.()
  end
end
