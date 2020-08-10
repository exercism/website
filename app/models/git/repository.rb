module Git
  class Repository
    def initialize(url)
      @url = url
    end

    def head_commit
      main_branch.target
    end

    def read_json_blob(commit, path)
      oid = find_blob_oid(commit, path)
      raw = read_blob(oid, "{}")
      JSON.parse(raw, symbolize_names: true)
    end

    def read_blob(oid, default = nil)
      blob = lookup(oid)
      blob.present? ? blob.text : default
    end

    %i[commit tree].each do |type|
      define_method "lookup_#{type}" do |oid|
        lookup(oid).tap do |object|
          raise 'wrong-type' if object.type != type
        end
      rescue Rugged::OdbError
        raise 'not-found'
      end
    end

    def find_blob_oid(commit, path)
      parts = path.split('/')
      target_filename = parts.pop
      dir = "#{parts.join('/')}/"

      commit.tree.walk_blobs do |obj_dir, obj|
        return obj[:oid] if obj[:name] == target_filename && obj_dir == dir
      end

      raise "No blob found: #{target_filename}"
    end

    def read_tree(commit, path)
      parts = path.split("/")
      dir_name = parts.pop
      root_path = parts.present? ? "#{parts.join('/')}/" : ""

      commit.tree.walk_trees do |obj_dir, obj|
        return lookup(obj[:oid]) if obj_dir == root_path && obj[:name] == dir_name
      end

      raise "No blob found: #{path}"
    end

    delegate :lookup, to: :rugged_repo

    private
    attr_reader :url

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
      @rugged_repo ||= begin
        if File.directory?(repo_dir)
          Rugged::Repository.new(repo_dir).tap do |r|
            # If we're in dev or test mode we want to just fetch
            # every time to get up to date. In production
            # we schedule this based of webhooks instead
            r.fetch('origin') unless Rails.env.production?
          end
        else
          Rugged::Repository.clone_at(url, repo_dir, bare: true)
        end
      end
    rescue StandardError => e
      Rails.logger.error "Failed to clone repo #{url}"
      Rails.logger.error e.message
      raise
    end

    MAIN_BRANCH_REF = "origin/master".freeze
    private_constant :MAIN_BRANCH_REF
  end
end
