module Git
  class Track
    extend Mandate::Memoize
    extend Git::HasGitFilepaths

    delegate :head_sha, :fetch!, :lookup_commit, :head_commit, to: :repo

    git_filepaths about: "docs/ABOUT.md",
                  snippet: "docs/SNIPPET.txt",
                  debugging_instructions: "exercises/shared/.docs/debug.md",
                  help: "exercises/shared/.docs/help.md",
                  tests: "exercises/shared/.docs/tests.md",
                  config: "config.json"

    def initialize(git_sha = "HEAD", repo_url: nil, repo: nil)
      raise "One of :repo or :repo_url must be specified" unless [repo, repo_url].compact.size == 1

      @repo = repo || Repository.new(repo_url: repo_url)
      @git_sha = git_sha
    end

    def test_regexp
      pattern = config[:test_pattern]
      Regexp.new(pattern.presence || "[tT]est")
    end

    def ignore_regexp
      pattern = config[:ignore_pattern]
      Regexp.new(pattern.presence || "[iI]gnore")
    end

    memoize
    def key_features
      config[:key_features].to_a
    end

    memoize
    def has_concept_exercises?
      config[:status][:concept_exercises]
    end

    memoize
    def has_test_runner?
      config[:status][:test_runner]
    end

    memoize
    def has_representer?
      config[:status][:representer]
    end

    memoize
    def has_analyzer?
      config[:status][:analyzer]
    end

    memoize
    def concept_exercises
      config[:exercises][:concept].to_a
    end

    memoize
    def practice_exercises
      config[:exercises][:practice].to_a
    end

    memoize
    def concepts
      config[:concepts].to_a
    end

    memoize
    def indent_style
      (online_editor[:indent_style] || 'space').to_sym
    end

    memoize
    def indent_size
      online_editor[:indent_size] || 2
    end

    memoize
    def ace_editor_language
      online_editor[:ace_editor_language]
    end

    memoize
    def highlightjs_language
      online_editor[:highlightjs_language]
    end

    memoize
    def average_run_time
      test_runner[:average_run_time] || 3.0
    end

    memoize
    def commit
      repo.lookup_commit(git_sha)
    end

    def find_exercise(uuid)
      find_concept_exercise(uuid) || find_practice_exercise(uuid)
    end

    def find_concept_exercise(uuid)
      concept_exercises.find { |e| e[:uuid] == uuid }
    end

    def find_practice_exercise(uuid)
      practice_exercises.find { |e| e[:uuid] == uuid }
    end

    def find_concept(uuid)
      concepts.find { |c| c[:uuid] == uuid }
    end

    private
    attr_reader :repo, :git_sha

    def absolute_filepath(filepath)
      filepath
    end

    memoize
    def online_editor
      config[:online_editor]
    end

    memoize
    def test_runner
      config[:test_runner]
    end
  end
end
