class TranslationRepo::Sync
  include Mandate

  initialize_with url: TranslationRepo::URL

  def call
    with_lock do
      clone! unless File.directory?(root / ".git")
      git!("sparse-checkout", "set", *sparse_dirs)
      git!("checkout", TranslationRepo::BRANCH)
      git!("pull", "--ff-only", "origin", TranslationRepo::BRANCH)
    end
  end

  private
  def root = TranslationRepo.root

  def sparse_dirs = (LocaleRoster.served - [LocaleRoster.default]).map { |locale| "locales/#{locale}" }

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
      yield if file.flock(File::LOCK_EX | File::LOCK_NB)
    end
  end
end
