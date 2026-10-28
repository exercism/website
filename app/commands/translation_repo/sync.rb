class TranslationRepo::Sync
  include Mandate

  initialize_with url: TranslationRepo::URL

  def call
    with_lock do
      clone! unless File.directory?(root / ".git")
      remove_stale_git_locks!
      pull!
    end
  end

  private
  def root = TranslationRepo.root

  # A git process that is killed part way through leaves its lock files behind,
  # and git then refuses to update the checkout again. The flock only covers the
  # Ruby process, and a git process it started can outlive it, so a lock file is
  # only treated as abandoned once nothing has written to it for STALE_LOCK_AGE.
  STALE_LOCK_AGE = 10.minutes
  private_constant :STALE_LOCK_AGE

  def remove_stale_git_locks!
    Dir.glob(root.join(".git", "{*.lock,info/*.lock,refs/**/*.lock}")).each do |file|
      FileUtils.rm_f(file) if File.mtime(file) < STALE_LOCK_AGE.ago
    rescue Errno::ENOENT
      nil
    end
  end

  # The clone checks out main, and nothing moves the checkout off it, so a sync
  # only pulls. On EFS, a `git checkout` of the branch already checked out still
  # checks every file for local changes, which is over a hundred thousand
  # network round trips on every push to the translation repo.
  def clone!
    git!("clone", "--depth", "1", "--single-branch", "--branch", TranslationRepo::BRANCH,
      url, root.to_s, chdir: root.dirname)
  end

  # A pull that is killed after writing some of the new files but before moving
  # HEAD leaves those files behind as local changes and untracked files, and every
  # later pull refuses to overwrite them. Nobody edits this checkout, so the files
  # git names are put back to HEAD or removed, and the pull is tried again. Only
  # the named files are touched, as a reset or clean would check every file on EFS.
  def pull!
    output, status = git("pull", "--ff-only", "origin", TranslationRepo::BRANCH)
    return output if status.success?

    modified = paths_after(output, MODIFIED_HEADING)
    untracked = paths_after(output, UNTRACKED_HEADING)
    raise "git pull failed: #{output}" if modified.empty? && untracked.empty?

    git!("checkout", "HEAD", "--", *modified) if modified.any?
    untracked.each { |path| FileUtils.rm_f(root / path) }
    git!("pull", "--ff-only", "origin", TranslationRepo::BRANCH)
  end

  MODIFIED_HEADING = "Your local changes to the following files would be overwritten by merge:".freeze
  UNTRACKED_HEADING = "The following untracked working tree files would be overwritten by merge:".freeze
  private_constant :MODIFIED_HEADING, :UNTRACKED_HEADING

  # git lists the files under each heading one per line, indented with a tab.
  def paths_after(output, heading)
    lines = output.lines.map(&:chomp)
    start = lines.index { |line| line.end_with?(heading) } or return []

    lines[(start + 1)..].take_while { |line| line.start_with?("\t") }.map(&:strip)
  end

  def git!(*args, chdir: root)
    output, status = git(*args, chdir:)
    raise "git #{args.first} failed: #{output}" unless status.success?

    output
  end

  # git's messages are parsed, so they are kept in English whatever the machine's locale.
  def git(*args, chdir: root)
    Open3.capture2e({ "LC_ALL" => "C" }, "git", *args, chdir: chdir.to_s)
  end

  def with_lock
    FileUtils.mkdir_p(root.dirname)
    File.open(root.dirname / "i18n.lock", File::RDWR | File::CREAT) do |file|
      next false unless file.flock(File::LOCK_EX | File::LOCK_NB)

      yield
      true
    end
  end
end
