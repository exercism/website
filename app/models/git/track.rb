module Git
  class Track
    extend Mandate::Memoize
    extend Git::HasGitFilepath

    attr_reader :repo

    delegate :head_sha, :fetch!, :lookup_commit, :head_commit, to: :repo

    git_filepath :about, file: "docs/ABOUT.md"
    git_filepath :snippet, file: "docs/SNIPPET.txt"
    git_filepath :representer_normalizations, file: "docs/REPRESENTER_NORMALIZATIONS.md"
    git_filepath :debugging_instructions, file: "exercises/shared/.docs/debug.md"
    git_filepath :help, file: "exercises/shared/.docs/help.md"
    git_filepath :tests, file: "exercises/shared/.docs/tests.md"
    git_filepath :representations, file: "exercises/shared/.docs/representations.md"
    git_filepath :config, file: "config.json"

    def initialize(git_sha = "HEAD", repo_url: nil, repo: nil)
      raise "One of :repo or :repo_url must be specified" unless [repo, repo_url].compact.size == 1

      @repo = repo || Repository.new(repo_url:)
      @git_sha = git_sha
    end

    memoize
    def title
      config[:language]
    end

    memoize
    def slug
      config[:slug]
    end

    memoize
    def blurb
      config[:blurb]
    end

    memoize
    def tags
      config[:tags].to_a
    end

    memoize
    def active?
      !!config[:active]
    end

    memoize
    def key_features
      config[:key_features].to_a
    end

    memoize
    def has_concept_exercises?
      !!status[:concept_exercises]
    end

    memoize
    def has_test_runner?
      !!status[:test_runner]
    end

    memoize
    def has_representer?
      !!status[:representer]
    end

    memoize
    def has_analyzer?
      !!status[:analyzer]
    end

    memoize
    def concept_exercises
      exercises[:concept].to_a
    end

    memoize
    def practice_exercises
      exercises[:practice].to_a
    end

    memoize
    def foregone_exercises
      exercises[:foregone].to_a
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
    def average_test_duration
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

    memoize
    def taught_concept_slugs
      concept_slugs = concepts.map { |c| c[:slug] }
      concept_exercise_concept_slugs = concept_exercises.flat_map { |e| e[:concepts].to_a }
      concept_exercise_concept_slugs & concept_slugs
    end

    memoize
    def approaches_snippet_extension
      config.dig(:approaches, :snippet_extension).presence || DEFAULT_SNIPPET_EXTENSION
    end

    private
    attr_reader :git_sha

    def absolute_filepath(filepath) = filepath

    memoize
    def online_editor
      config[:online_editor] || {}
    end

    memoize
    def test_runner
      config[:test_runner] || {}
    end

    memoize
    def status
      config[:status] || {}
    end

    memoize
    def exercises
      config[:exercises] || {}
    end

    DEFAULT_SNIPPET_EXTENSION = "txt".freeze
    private_constant :DEFAULT_SNIPPET_EXTENSION
  end
end
