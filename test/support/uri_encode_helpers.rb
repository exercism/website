module UriEncodeHelpers
  def uri_encode(uri)
    # rubocop:disable Lint/UriEscapeUnescape
    Addressable::URI.encode(uri)
    # rubocop:enable Lint/UriEscapeUnescape
  end
end
