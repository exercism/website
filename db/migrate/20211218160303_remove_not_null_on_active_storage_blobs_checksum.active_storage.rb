# This migration comes from active_storage (originally 20211119233751)
class RemoveNotNullOnActiveStorageBlobsChecksum < ActiveRecord::Migration[7.0]
  def up
    execute("ALTER TABLE active_storage_blobs MODIFY COLUMN checksum VARCHAR(255) NULL, ALGORITHM=INPLACE, LOCK=NONE")
  end

  def down
    change_column_null(:active_storage_blobs, :checksum, false)
  end
end
