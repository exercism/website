class Track::SetFileSystemPermissions
  include Mandate

  initialize_with :track

  def call
    return if safe_directory_already_set?

    add_safe_directory!

    # A redeploy of the website is required to pick up the new safe directory
    trigger_redeploy!
  end

  private
  def safe_directory_already_set?
    Kernel.system("git config --global --get safe.directory #{safe_directory}")
  end

  def add_safe_directory!
    Kernel.system("git config --global --add safe.directory #{safe_directory}")
  end

  def trigger_redeploy! = Infrastructure::TriggerRedeploy.()

  def safe_directory = "/mnt/efs/repos/#{track.slug}"
end
