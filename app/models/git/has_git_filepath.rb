module Git
  module HasGitFilepath
    # To be able to include this module, the including class must have:
    # - A member named "repo" of type Git::Repository
    # - A method named "absolute_filepath" that takes a relative path
    #   to a git file and returns its absolute path
    def git_filepath(field, file:, append_file: nil)
      json_file = file.end_with?('.json')
      toml_file = file.end_with?('.toml')

      if json_file
        read_method = "read_json_blob"
      elsif toml_file
        read_method = "read_toml_blob"
      else
        read_method = "read_text_blob"
      end

      # Define a <field> method that stored a memoized version of the contents
      # of the file with the specified filepath as retrieved from Git
      define_method field do
        iv = "@__#{field}__"
        return instance_variable_get(iv) if instance_variable_defined?(iv)

        file_content = repo.send(read_method, commit, absolute_filepath(file))

        unless json_file || toml_file
          file_content.strip!
          file_content << "\n\n" if append_file
          file_content << repo.send(read_method, commit, absolute_filepath(append_file)) if append_file
          file_content.strip!
        end

        instance_variable_set(iv, file_content)
      end

      # Define a <field>_filepath method to allow easy access to the filepath
      define_method "#{field}_filepath" do
        file
      end

      # Define a <field>_absolute_filepath method to allow easy access to the filepath
      define_method "#{field}_absolute_filepath" do
        absolute_filepath(file)
      end

      # Define a <field>_exists? method to allow checking if the file exists in git
      define_method "#{field}_exists?" do
        repo.file_exists?(commit, absolute_filepath(file))
      end
    end
  end
end
