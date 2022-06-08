module ViewComponents
  class BlogPost < ViewComponent
    extend Mandate::Memoize

    initialize_with :post

    def to_s
      render template: 'components/blog_post', locals: { post: }
    end
  end
end
