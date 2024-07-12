require "test_helper"

class Track::SetFileSystemPermissionsTest < ActiveSupport::TestCase
  test "adds track repo to git safe directories" do
    track = create :track

    Github::DispatchWorkflow.stubs(:call)
    Kernel.expects(:system).with("git config --global --add safe.directory /mnt/efs/repos/#{track.slug}")

    Track::SetFileSystemPermissions.(track)
  end

  test "dispatches deploy workflow" do
    track = create :track

    Github::DispatchWorkflow.expects(:call).with("website", "deploy.yml")
    Kernel.stubs(:system)

    Track::SetFileSystemPermissions.(track)
  end
end
