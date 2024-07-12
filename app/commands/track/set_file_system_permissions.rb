class Track::SetFileSystemPermissions
  include Mandate

  initialize_with :track

  def call
    add_safe_directory!

    # A redeploy of the website is required to pick up the new safe directory
    trigger_redeploy!
  end

  private
  def add_safe_directory!
    Kernel.system("git config --global --add safe.directory /mnt/efs/repos/#{track.slug}")
  end

  def trigger_redeploy!
    Github::DispatchWorkflow.("website", "deploy.yml")
  end
end
