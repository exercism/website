class UpdateWebsiteCopyJob < ApplicationJob
  queue_as :default

  def perform
    Git::WebsiteCopy.update!
  end
end
