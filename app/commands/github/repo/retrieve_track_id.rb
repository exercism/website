class Github::Repo::RetrieveTrackId
  include Mandate

  initialize_with :repo

  def call = Track.where(repo_url:).pick(:id)

  private
  def repo_url
    uri = URI(repo)
    if uri.scheme.nil?
      uri.scheme = "https"
      uri.host = "github.com"
      uri.path = "/#{uri.path}"
    end
    uri.path.gsub!(/-(test-runner|analyzer|representer)$/, '')
    uri.to_s
  end
end
