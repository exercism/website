require_relative "table_migration"

module V2ETL
  module TableMigrations
    class MigrateSubmissionFiles < TableMigration
      include Mandate

      def table_name
        "submission_files"
      end

      def model
        Submission::File
      end

      def call
        # TODO: Are the digests created using the same algorithm
        # in v2 vs v3. Check and update this comment. If not, does it matter?
        rename_column :file_contents_digest, :digest

        # TODO: Upload to s3+efs of all existing submission_files
        # then set this as part of that. This should probably be a load
        # of ActiveJobs specifically for this.
        add_non_nullable_column :uri, :string, "''"

        # TOOD: We're leaving file_contents here atm, but
        # we either need to delete that at the end of this
        # or more likely at some point in the future. If it's the
        # later then we need an issue on GH for this.
        change_column_null :file_contents, true

        # We've kept the id of submissions to be the same
        # as the id of iterations, which allows us to
        # effectively just rename the column.
        remove_foreign_key column: :iteration_id
        remove_index column: :iteration_id
        rename_column :iteration_id, :submission_id
        add_foreign_key :submissions
      end
    end
  end
end
