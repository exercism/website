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
  # and git then refuses to update the checkout again. The site only reads the
  # checkout, and the flock lets one sync run at a time, so any lock file found
  # here was left by a sync that was killed.
  def remove_stale_git_locks!
    Dir.glob(root.join(".git", "{*.lock,info/*.lock,refs/**/*.lock}")).each { |file| FileUtils.rm_f(file) }
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
