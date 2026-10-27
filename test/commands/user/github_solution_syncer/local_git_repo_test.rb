require 'test_helper'

class User::GithubSolutionSyncer::LocalGitRepoTest < ActiveSupport::TestCase
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
  def within_repo
    Dir.mktmpdir do |parent_dir|
      dir = "#{parent_dir}/repo"
      FileUtils.mkdir_p(dir)

      repo = User::GithubSolutionSyncer::LocalGitRepo.new(mock, "main", "new-branch")
      repo.instance_variable_set(:@path, dir)

      yield repo, dir
    end
  end
end
