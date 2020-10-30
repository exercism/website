module Git
  class Exercise
    extend Mandate::Memoize
    extend Mandate::InitializerInjector

    def self.for_solution(solution)
      new(
        solution.track.slug,
        solution.git_slug,
        solution.git_sha
      )
    end

    initialize_with :track_slug, :exercise_slug, :git_sha

    memoize
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

    memoize
    def editor_solution_files
      resp = RestClient.get(url_for(:editor_files))
      data = JSON.parse(resp.body)
      data['solution_files']
    end

    memoize
    def code_filepaths
      resp = RestClient.get(url_for(:code_filepaths))
      data = JSON.parse(resp.body)
      OpenStruct.new(data['filepaths'])
    end

    memoize
    def code_files
      resp = RestClient.get(url_for(:code_files))
      data = JSON.parse(resp.body)
      data['files']
    end

    private
    def url_for(endpoint, query_parts = {})
      base = [
        Exercism.config.git_server_url,
        "exercises",
        track_slug,
        exercise_slug,
        endpoint
      ].join("/")

      query = {
        # TOOD: Switch these once auto-updating is done
        # "git_sha": git_sha
        "git_sha": "HEAD"
      }.merge(query_parts).
        map { |k, v| "#{k}=#{v}" }.
        join("&")

      [base, query].join("?")
    end
  end
end
