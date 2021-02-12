module Git
  module HasGitFilepaths
    def git_filepaths(**fields_to_filepaths)
      fields_to_filepaths = Hash(fields_to_filepaths)
      fields_to_filepaths.each do |field, filepath|
        filepath.end_with?('.json') ? read_method = "read_json_blob" : read_method = "read_text_blob"

        # Define a <field> method that stored a memoized version of the contents
        # of the file with the specified filepath as retrieved from Git
        define_method field do
          iv = "@__#{field}__"
          return instance_variable_get(iv) if instance_variable_defined?(iv)

          instance_variable_set(iv, send(read_method, commit, filepath))
        end

        # Define a <field>_filepath method to allow easy access to the filepath
        define_method "#{field}_filepath" do
          filepath
        end
      end
    end
  end
end
