module Git
  class Exercise
    def initialize(repo, slug, commit, track_config)
      @repo = repo
      @slug = slug
      @commit = commit
      @track_config = track_config
    end
      
    def filenames
      files.map {|defn|defn[:full]}
    end
    
    def read_file_blob(path)
      mapped = files.map {|f| [f[:full], f[:oid]] }.to_h
      mapped[path] ? repo.read_blob(mapped[path]) : nil
    end

    def version
      config[:version]
    end

    private
    attr_reader :repo, :slug, :commit, :track_config

    #TODO: Memoize
    def files
      tree.walk(:preorder).map { |root, entry|
        next if entry[:type] == :tree
        entry[:full] = "#{root}#{entry[:name]}"
        entry
      }.compact
    end
    
    def tree
      oid = commit.tree['exercises'][:oid]
      exercises = repo.lookup_tree(oid)
      repo.lookup_tree(exercises[slug][:oid])
    end

    #TODO memoize
    def config
      HashWithIndifferentAccess.new(
        JSON.parse(read_file_blob('.meta/config.json'))
      )
    end
  end
end
