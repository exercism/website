module Git
  class Exercise
    def self.for_solution(solution)
      new(
        solution.track.slug,
        solution.git_slug,
        solution.git_sha
      )
    end

    def initialize(track_slug, exercise_slug, git_sha)
      @track_slug = track_slug
      @exercise_slug = exercise_slug
      @git_sha = git_sha
    end

    def data
      resp = RestClient.get(url_for(:data))
      data = JSON.parse(resp.body)
      OpenStruct.new(data['exercise'])
    end

    def file(filename)
      resp = RestClient.get(url_for(:file, { filename: filename }))
      data = JSON.parse(resp.body)
      data['content']

      # TODO: Rescue 404 here
      # rescue
      #  nil
    end

    def code_filepaths
      resp = RestClient.get(url_for(:code_filepaths))
      data = JSON.parse(resp.body)
      OpenStruct.new(data['filepaths'])
    end

    def code_files
      resp = RestClient.get(url_for(:code_files))
      data = JSON.parse(resp.body)
      OpenStruct.new(data['files'])
    end

    private
    attr_reader :track_slug, :exercise_slug, :git_sha

    def url_for(endpoint, query_parts = {})
      base = [
        Exercism.config.git_server_url,
        "exercises",
        track_slug,
        exercise_slug,
        endpoint
      ].join("/")

      query = {
        "git_sha": git_sha
      }.merge(query_parts).
        map { |k, v| "#{k}=#{v}" }.
        join("&")

      [base, query].join("?")
    end
  end
end
