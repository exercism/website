class CommunityVideo::Retrieve
  include Mandate

  initialize_with :url

  def call
    raise InvalidCommunityVideoUrlError unless url.present?

    if youtube?
      CommunityVideo::RetrieveFromYoutube.(url)
    elsif vimeo?
      CommunityVideo::RetrieveFromVimeo.(url)
    else
      raise InvalidCommunityVideoUrlError
    end
  end

  def youtube?
    return true if url.starts_with?('https://youtu.be/')
    return true if url.starts_with?('https://youtube.com/')
    return true if url.starts_with?(%r{https://[a-z]+\.youtube.com/})

    false
  end

  def vimeo?
    return true if url.starts_with?("https://vimeo.com/")
    return true if url.starts_with?("https://player.vimeo.com/")

    false
  end
end
