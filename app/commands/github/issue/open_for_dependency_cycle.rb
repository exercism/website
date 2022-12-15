class Github::Issue::OpenForDependencyCycle
  include Mandate

  queue_as :default

  initialize_with :track

  def call
    Github::Issue::Open.(repo, title, body)
  end

  private
  def repo
    "exercism/#{track.slug}"
  end

  def title
    "🤖 Concept prerequisite cycle found in commit #{track.synced_to_git_sha[0..5]}"
  end

  def body
    <<~BODY.strip
      We found a concept prerequisite cycle in the `config.json` file in commit #{track.synced_to_git_sha}.

      Such a cycle occurs when Concept Exercise A teaches concept X and has concept Y as a prerequisite, whereas Concept Exercise B teaches concept Y and has concept X as a prerequisite. The cycle can also be indirect, in which case there are intermediate Concept Exercises involved.

      These prerequisite cycles should be removed to have the track work properly on the website.

      Please tag @exercism/maintainers-admin if you require more information.
    BODY
  end
end
