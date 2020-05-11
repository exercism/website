module Git
  class Repository
    def initialize(url)
      @url = url
    end

    def head_commit
      main_branch.target
    end

    def read_json_blob(oid)
      raw = read_blob(oid, "{}")
      JSON.parse(raw, symbolize_names: true)
    end

    def read_blob(oid, default=nil)
      blob = lookup(oid)
      blob.present?? blob.text : default
    #rescue => e
    #  Rails.logger.info e.message
    #  default
    end

    [:commit, :tree].each do |type|
      define_method "lookup_#{type}" do |oid|
        lookup(oid).tap do |object|
          raise 'wrong-type' if object.type != type
        end
      rescue Rugged::OdbError => e
        raise 'not-found'
      end
    end

    private
    attr_reader :url

    def lookup(oid)
      rugged_repo.lookup(oid)
    end

    def main_branch
      rugged_repo.branches[MAIN_BRANCH_REF]
    end
   
    def repo_dir
      url_hash = Digest::SHA1.hexdigest(url)
      local_name = url.split("/").last
      base_dir = Rails.application.config_for(:git)[:base_dir]
      "#{base_dir}/#{url_hash}-#{local_name}"
    end
 
    # TODO: Memoize
    def rugged_repo
      if File.directory?(repo_dir)
        r = Rugged::Repository.new(repo_dir)

        # If we're in dev or test mode we want to just fetch
        # every time to get up to date. In production
        # we schedule this based of webhooks instead
        r.fetch('origin') unless Rails.env.production?
        r
      else
        Rugged::Repository.clone_at(url, repo_dir, bare: true)
      end
    rescue => e
      Rails.logger.error "Failed to clone repo #{url}"
      Rails.logger.error e.message
      raise
    end


    MAIN_BRANCH_REF = "origin/master"
    private_constant :MAIN_BRANCH_REF
  end
end

