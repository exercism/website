class Exercise
  class RetrieveGitData
    include Mandate

    initialize_with :track_slug, :exercise_slug, :git_sha

    def call
      resp = RestClient.get(url)
      data = JSON.parse(resp.body)
      OpenStruct.new(data['exercise'])
    end

    private
    def url
      [
        Exercism.config.git_server_url,
        "exercises",
        track_slug,
        exercise_slug,
        git_sha
      ].join("/")
    end
  end
end
