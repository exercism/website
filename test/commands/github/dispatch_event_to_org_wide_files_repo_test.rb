require "test_helper"

class Github::DispatchEventToOrgWideFilesRepoTest < ActiveJob::TestCase
  test "dispatch repository event for single repo" do
    stub_request(:post, "https://api.github.com/repos/exercism/org-wide-files/dispatches").
      with(body: '{"event_type":"repo_update","client_payload":{"repos":["exercism/ruby"],"pusher":"user17"}}')

    Github::DispatchEventToOrgWideFilesRepo.(:repo_update, ["exercism/ruby"], 'user17')

    assert_requested(:post, "https://api.github.com/repos/exercism/org-wide-files/dispatches", times: 1) do |req|
      req.body == '{"event_type":"repo_update","client_payload":{"repos":["exercism/ruby"],"pusher":"user17"}}'
    end
  end

  test "dispatch repository event for multiples repos" do
    stub_request(:post, "https://api.github.com/repos/exercism/org-wide-files/dispatches").
      with(body: '{"event_type":"repo_update","client_payload":{"repos":["exercism/website","exercism/configlet"],"pusher":"user17"}}') # rubocop:disable Layout/LineLength

    Github::DispatchEventToOrgWideFilesRepo.(:repo_update, ["exercism/website", "exercism/configlet"], 'user17')

    assert_requested(:post, "https://api.github.com/repos/exercism/org-wide-files/dispatches", times: 1) do |req|
      req.body == '{"event_type":"repo_update","client_payload":{"repos":["exercism/website","exercism/configlet"],"pusher":"user17"}}' # rubocop:disable Layout/LineLength
    end
  end

  test "raises for unknown event type" do
    assert_raises do
      Github::DispatchEventToOrgWideFilesRepo.(:unknown, ["exercism/website"], 'user17')
    end
  end
end
