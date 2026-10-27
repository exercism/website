require 'test_helper'

class ToolingJob::UploadToEFSTest < ActiveSupport::TestCase
  test "writes files into the directory" do
    file = Struct.new(:filename, :utf8_content)
    Dir.mktmpdir do |tmp_dir|
      efs_dir = "#{tmp_dir}/job"
      files = [
        file.new("foo.rb", "foo"),
        file.new("subdir/bar.rb", "bar")
      ]

      ToolingJob::UploadToEFS.(efs_dir, files)

      assert_equal "foo", File.read("#{efs_dir}/foo.rb")
      assert_equal "bar", File.read("#{efs_dir}/subdir/bar.rb")
    end
  end

  test "ignores files with invalid filenames" do
    file = Struct.new(:filename, :utf8_content)
    Dir.mktmpdir do |tmp_dir|
      efs_dir = "#{tmp_dir}/jobs/job"
      files = [
        file.new("../../foo.rb", "foo"),
        file.new("subdir/../../bar.rb", "bar"),
        file.new("baz.rb", "baz")
      ]

      ToolingJob::UploadToEFS.(efs_dir, files)

      written = Dir.glob("#{tmp_dir}/**/*").select { |path| File.file?(path) }
      assert_equal ["#{efs_dir}/baz.rb"], written
    end
  end
end
