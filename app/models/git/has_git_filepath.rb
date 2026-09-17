module Git
  module HasGitFilepath
    # To be able to include this module, the including class must have:
    # - A member named "repo" of type Git::Repository
    # - A method named "absolute_filepath" that takes a relative path
    #   to a git file and returns its absolute path
    #
    # translatable: true reads the file (and its append file, which is a
    # separate blob with its own translation) in the current locale.
    def git_filepath(field, file:, append_file: nil, translatable: false)
      if translatable
        read_method = "read_translated_text_blob"
      elsif file.instance_of?(Proc)
        read_method = "read_text_blob"
      else
        json_file = file.end_with?('.json')
        toml_file = file.end_with?('.toml')

        if json_file
          read_method = "read_json_blob"
        elsif toml_file
          read_method = "read_toml_blob"
        else
          read_method = "read_text_blob"
        end
      end

      # Define a <field> method that stored a memoized version of the contents
      # of the file with the specified filepath as retrieved from Git
      define_method field do
        iv = translatable ? "@__#{field}_#{I18n.locale.to_s.tr('-', '_')}__" : "@__#{field}__"
        return instance_variable_get(iv) if instance_variable_defined?(iv)

        file_content = repo.send(read_method, commit, send("#{field}_absolute_filepath"))

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
        iv = "@__#{field}_filepath__"
        return instance_variable_get(iv) if instance_variable_defined?(iv)

        filepath = file.is_a?(Proc) ? file.(self) : file
        instance_variable_set(iv, filepath)
      end

      # Define a <field>_absolute_filepath method to allow easy access to the filepath
      define_method "#{field}_absolute_filepath" do
        absolute_filepath(send("#{field}_filepath"))
      end

      # Define a <field>_translated? method. True in English, or when the file
      # (and its append file) have translations for exactly these versions
      if translatable
        define_method "#{field}_translated?" do
          [send("#{field}_absolute_filepath"), (absolute_filepath(append_file) if append_file)].compact.
            all? { |path| repo.translated?(commit, path) }
        end
      end

      # Define a <field>_exists? method to allow checking if the file exists in git
      define_method "#{field}_exists?" do
        repo.file_exists?(commit, send("#{field}_absolute_filepath"))
      end
    end
  end
end
