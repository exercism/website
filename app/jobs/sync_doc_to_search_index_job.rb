class SyncDocToSearchIndexJob < ApplicationJob
  queue_as :default

  def perform(doc)
    Document::SyncToSearchIndex.(doc)
  end
end
