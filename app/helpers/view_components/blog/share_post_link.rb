class ViewComponents::Blog::SharePostLink < ViewComponents::ViewComponent
  initialize_with :post

  def to_s = ReactComponents::Common::ShareLink.new(AssembleBlogPostSharePanel.(post)).to_s
end
