module UriEncodeHelpers
  def uri_encode(uri)
    Addressable::URI.encode(uri)
  end
end
