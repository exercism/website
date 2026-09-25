class TranslationRepo::Sync
  include Mandate

  initialize_with url: TranslationRepo::URL

  def call
    with_lock do
      clone! unless File.directory?(root / ".git")
      remove_stale_git_locks!
      git!("sparse-checkout", "set", *sparse_dirs)
      git!("checkout", TranslationRepo::BRANCH)
      git!("pull", "--ff-only", "origin", TranslationRepo::BRANCH)
    end
  end

  private
  def root = TranslationRepo.root

  def sparse_dirs = (I18n.available_locales - [I18n.default_locale]).map { |locale| "locales/#{locale}" }

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

  def clone!
    git!("clone", "--depth", "1", "--single-branch", "--branch", TranslationRepo::BRANCH, "--no-checkout",
      url, root.to_s, chdir: root.dirname)
  end

  def git!(*args, chdir: root)
    output, status = Open3.capture2e("git", *args, chdir: chdir.to_s)
    raise "git #{args.first} failed: #{output}" unless status.success?

    output
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
