require "test_helper"

class Track::SetFileSystemPermissionsTest < ActiveSupport::TestCase
  test "adds track repo to git safe directories if not already added" do
    track = create :track

    Github::DispatchWorkflow.stubs(:call)
    Kernel.stubs(:system).with("git config --global --get safe.directory /mnt/efs/repos/#{track.slug}").returns(false)
    Kernel.expects(:system).with("git config --global --add safe.directory /mnt/efs/repos/#{track.slug}")

    Track::SetFileSystemPermissions.(track)
  end

  test "does not add track repo to git safe directories if already added" do
    track = create :track

    Github::DispatchWorkflow.expects(:call).never
    Kernel.stubs(:system).with("git config --global --get safe.directory /mnt/efs/repos/#{track.slug}").returns(true)
    Kernel.expects(:system).with("git config --global --add safe.directory /mnt/efs/repos/#{track.slug}").never

    Track::SetFileSystemPermissions.(track)
  end

  test "dispatches deploy workflow" do
    track = create :track

    Infrastructure::TriggerRedeploy.expects(:call)
    Kernel.stubs(:system)

    Track::SetFileSystemPermissions.(track)
  end
end
