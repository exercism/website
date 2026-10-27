require "test_helper"

class User::GithubSolutionSyncer
  class LocalGitRepoTest < ActiveSupport::TestCase
    test "create_branch creates a new branch" do
      with_local_repo("feature/new") do |repo, dir|
        repo.send(:create_branch)

        assert_equal "feature/new", current_branch(dir)
      end
    end

    test "create_branch checks out a branch that already exists" do
      with_local_repo("existing") do |repo, dir|
        run_git(dir, "branch", "existing")
        run_git(dir, "commit", "--allow-empty", "-m", "Second commit")

        repo.send(:create_branch)

        assert_equal "existing", current_branch(dir)
        assert_equal "Initial commit", last_commit_message(dir)
      end
    end

    test "create_branch treats the branch name as a literal argument" do
      name = "odd name $(touch marker)"
      with_local_repo(name) do |repo, dir|
        assert_raises(RuntimeError) { repo.send(:create_branch) }

        refute File.exist?(File.join(dir, "marker"))
        refute File.exist?(Rails.root.join("marker"))
      end
    end

    test "commit_all commits changed files" do
      with_local_repo("main") do |repo, dir|
        repo.write_file("solutions/ruby/bob/1/bob.rb", "class Bob\nend\n")
        repo.commit_all("Sync Bob")

        assert_equal "Sync Bob", last_commit_message(dir)
        assert_empty run_git(dir, "status", "--porcelain")
      end
    end

    test "commit_all does nothing when there are no changes" do
      with_local_repo("main") do |repo, dir|
        repo.commit_all("Nothing to sync")

        assert_equal "Initial commit", last_commit_message(dir)
      end
    end

    test "write_file writes files into the working tree" do
      within_repo do |repo, dir|
        repo.write_file("solutions/ruby/bob/1/bob.rb", "bob")

        assert_equal "bob", File.read("#{dir}/solutions/ruby/bob/1/bob.rb")
      end
    end

    test "write_file ignores invalid paths" do
      within_repo do |repo, dir|
        repo.write_file("../foo.rb", "foo")
        repo.write_file(".git/config", "config")
        repo.write_file("solutions/../.git/info/foo", "foo")

        refute File.exist?(File.join(File.dirname(dir), "foo.rb"))
        refute File.exist?("#{dir}/.git")
      end
    end

    test "write_file does not follow links out of the working tree" do
      Dir.mktmpdir do |outside_dir|
        within_repo do |repo, dir|
          File.symlink(outside_dir, "#{dir}/linked")
          File.symlink("#{outside_dir}/target.rb", "#{dir}/link.rb")

          repo.write_file("linked/foo.rb", "foo")
          repo.write_file("link.rb", "foo")

          assert_empty Dir.children(outside_dir)
        end
      end
    end

    private
    def with_local_repo(new_branch_name)
      syncer = build(:user_github_solution_syncer)
      repo = LocalGitRepo.new(syncer, "main", new_branch_name, token: "token")

      Dir.mktmpdir do |dir|
        run_git(dir, "init", "--initial-branch=main")
        run_git(dir, "config", "user.name", "Test")
        run_git(dir, "config", "user.email", "test@example.com")
        run_git(dir, "commit", "--allow-empty", "-m", "Initial commit")

        repo.instance_variable_set(:@path, dir)
        yield repo, dir
      end
    end

    def within_repo
      Dir.mktmpdir do |parent_dir|
        dir = "#{parent_dir}/repo"
        FileUtils.mkdir_p(dir)

        repo = LocalGitRepo.new(mock, "main", "new-branch")
        repo.instance_variable_set(:@path, dir)

        yield repo, dir
      end
    end

    def run_git(dir, *args)
      stdout, status = Open3.capture2("git", "-C", dir, *args)
      raise "git #{args.first} failed" unless status.success?

      stdout
    end

    def current_branch(dir) = run_git(dir, "rev-parse", "--abbrev-ref", "HEAD").strip
    def last_commit_message(dir) = run_git(dir, "log", "-1", "--format=%s").strip
  end
end
