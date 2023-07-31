module API
  class DocsController < BaseController
    skip_before_action :authenticate_user!
    before_action :authenticate_user

    def index
      render json: AssembleDocs.(params)
    end
  end
end
