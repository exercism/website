require 'test_helper'

module Git
  class TrackTest < ActiveSupport::TestCase
    test "passing_repo_works" do
      repo = Git::Repository.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      track = Git::Track.new(:csharp, repo: repo)
      assert_equal(/.+test[.]rb$/, track.test_regexp)
    end

    test "passing_repo_url_works" do
      track = Git::Track.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      assert_equal(/.+test[.]rb$/, track.test_regexp)
    end

    test "passing_both_repo_and_repo_url_raises" do
      assert_raises do
        Git::Repository.new(track_slug, repo_url: "foobar", repo: "barfoo")
      end
    end

    test "passing_neither_repo_and_repo_url_raises" do
      assert_raises do
        Git::Repository.new(track_slug)
      end
    end

    test "monorepo_test_regexp" do
      track = Git::Track.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      assert_equal(/.+test[.]rb$/, track.test_regexp)
    end

    test "monorepo_ignore_regexp" do
      track = Git::Track.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      assert_equal(/[iI]gnore/, track.ignore_regexp)
    end

    test "monorepo_about" do
      track = Git::Track.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      expected = "C# is a multi-paradigm, statically-typed programming language with object-oriented, declarative, functional, generic, lazy, integrated querying features and type inference.\n\nC# is a modern language that is constantly being updated. It is also fully open-source and runs on a wide variety of runtimes.\n" # rubocop:disable Layout/LineLength
      assert_equal(expected, track.about)
    end

    test "monorepo_snippet" do
      track = Git::Track.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      expected = "class HelloWorld\n{\n    string Hello()\n    {\n        return \"Hello, World!\";\n    }\n}\n"
      assert_equal(expected, track.snippet)
    end

    test "monorepo_key_features" do
      track = Git::Track.new(:csharp, repo_url: TestHelpers.git_repo_url("v3-monorepo"))
      expected = ["Modern", "Cross-platform", "Multi-paradigm", "General purpose", "Tooling", "Documentation"]
      assert_equal(expected, track.key_features.map { |f| f[:title] })
    end

    test "retrieves_test_regexp" do
      skip # TODO: Renable when not in monorepo
      track = Git::Track.new("track-with-exercises", :ruby)
      assert_equal(/test/, track.test_regexp)
    end

    test "has_correct_default_test_regexp" do
      skip # TODO: Renable when not in monorepo
      track = Git::Track.new(TestHelpers.git_repo_url("track-naked"), :ruby)
      assert_equal(/[tT]est/, track.test_regexp)
    end

    test "retrieves_ignore_regexp" do
      skip # TODO: Renable when not in monorepo
      track = Git::Track.new(TestHelpers.git_repo_url("track-with-exercises"), :ruby)
      assert_equal(/[iI]gno/, track.ignore_regexp)
    end

    test "has_correct_default_ignore_regexp" do
      skip # TODO: Renable when not in monorepo
      track = Git::Track.new(TestHelpers.git_repo_url("track-naked"), :ruby)
      assert_equal(/[iI]gnore/, track.ignore_regexp)
    end
  end
end
