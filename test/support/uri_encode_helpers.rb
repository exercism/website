module UriEncodeHelpers
  def uri_encode(uri)
    # rubocop:disable Lint/UriEscapeUnescape
    URI.encode(uri)
    # rubocop:enable Lint/UriEscapeUnescape
  end
end
