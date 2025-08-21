class User::GithubSolutionSyncer
  class WithGitContext
    include Mandate

    def initialize(&block)
      @block = block
    end

    def call
      # If it doesn't, then this is a naked repo, so create it.
      Dir.mktmpdir do |dir|
        git_dir = File.join(dir, '.git')
        work_tree = dir

        git = lambda do |*args|
          system("git", "--git-dir=#{git_dir}", "--work-tree=#{work_tree}", *args, exception: true)
        end

        block.(git)
      end
    end

    private
    attr_reader :block
  end
end
