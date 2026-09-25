require "test_helper"

class TranslationRepo::SyncTest < ActiveSupport::TestCase
  setup do
    TranslationRepo.expire!
    @root = Pathname.new(Dir.mktmpdir)
    TranslationRepo.stubs(root: @root / "i18n")

    @upstream = Pathname.new(Dir.mktmpdir)
    git!("init", "-q", "-b", "main")
    write!("locales.json", "{}")
    write!("locales/hu/website/backend.json", { a: "hu" }.to_json)
    write!("locales/nl/website/backend.json", { a: "nl" }.to_json)
    write!("locales/de/website/backend.json", { a: "de" }.to_json)
    commit!("one")
  end

  teardown do
    TranslationRepo.expire!
    TranslationRepo.unstub(:root)
    FileUtils.rm_rf(@root)
    FileUtils.rm_rf(@upstream)
  end

  test "clones shallow, on main, with only the served locales" do
    assert sync!

    assert_equal head, TranslationRepo.version
    assert_equal %w[locales.json locales/hu/website/backend.json], checked_out
    assert File.exist?(TranslationRepo.root / ".git" / "shallow")
    assert_equal "1", `git -C #{TranslationRepo.root} rev-list --count HEAD`.strip
  end

  test "pulls what was pushed and widens to newly served locales" do
    sync!

    write!("locales/hu/website/backend.json", { a: "hu2" }.to_json)
    commit!("two")
    with_available_locales(:hu, :nl) { sync! }

    assert_equal head, TranslationRepo.version
    assert_equal %w[locales.json locales/hu/website/backend.json locales/nl/website/backend.json], checked_out
    assert_equal({ "a" => "hu2" }, JSON.parse(File.read(TranslationRepo.backend_catalog_path(:hu))))
  end

  test "a second sync skips while the first holds the lock" do
    sync!
    before = head

    write!("locales/hu/website/backend.json", { a: "hu2" }.to_json)
    commit!("two")

    File.open(TranslationRepo.root.dirname / "i18n.lock", File::RDWR | File::CREAT) do |lock|
      lock.flock(File::LOCK_EX)
      refute sync!
      assert_equal before, TranslationRepo.version
    end

    assert sync!
    TranslationRepo.expire!
    assert_equal head, TranslationRepo.version
  end

  test "pulls past lock files that nothing has written to for over ten minutes" do
    sync!

    write!("locales/hu/website/backend.json", { a: "hu2" }.to_json)
    commit!("two")
    abandoned = 11.minutes.ago.to_time
    %w[ORIG_HEAD.lock index.lock shallow.lock refs/heads/main.lock].each { |lock| touch_lock!(lock, abandoned) }

    assert sync!

    TranslationRepo.expire!
    assert_equal head, TranslationRepo.version
    assert_equal({ "a" => "hu2" }, JSON.parse(File.read(TranslationRepo.backend_catalog_path(:hu))))
  end

  test "leaves a recent lock file alone, as its git process may still be running" do
    sync!
    before = TranslationRepo.version

    write!("locales/hu/website/backend.json", { a: "hu2" }.to_json)
    commit!("two")
    touch_lock!("ORIG_HEAD.lock", 9.minutes.ago.to_time)

    assert_raises(RuntimeError) { sync! }

    assert File.exist?(TranslationRepo.root / ".git" / "ORIG_HEAD.lock")
    TranslationRepo.expire!
    assert_equal before, TranslationRepo.version
  end

  private
  def touch_lock!(lock, mtime)
    file = TranslationRepo.root / ".git" / lock
    FileUtils.touch(file)
    File.utime(mtime, mtime, file)
  end

  def sync! = TranslationRepo::Sync.(url: "file://#{@upstream}")

  def git!(*args) = system("git", *args, chdir: @upstream.to_s, exception: true, out: File::NULL, err: File::NULL)

  def write!(path, text)
    file = @upstream / path
    FileUtils.mkdir_p(file.dirname)
    File.write(file, text)
  end

  def commit!(message)
    git!("add", "-A")
    git!("-c", "user.name=test", "-c", "user.email=test@exercism.org", "commit", "-q", "-m", message)
  end

  def head = `git -C #{@upstream} rev-parse HEAD`.strip

  def checked_out
    Dir.chdir(TranslationRepo.root) { Dir.glob("{locales.json,locales/**/*}").select { |f| File.file?(f) } }.sort
  end
end
