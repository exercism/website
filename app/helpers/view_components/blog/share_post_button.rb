class ViewComponents::Blog::SharePostButton < ViewComponents::ViewComponent
  initialize_with :post

  def to_s = ReactComponents::Common::ShareButton.new(SerializeBlogPostForSharing.(post)).to_s
end
