class RaiseSnippetLimitOnIterationsAndSolutions < ActiveRecord::Migration[7.1]
  def up
    return if Rails.env.production?

    # Snippets can now be up to 3,000 characters plus the "\n\n..." suffix.
    # A VARCHAR keeps its 2-byte length prefix up to 16,383 utf8mb4 characters,
    # so this runs in place without copying the table.
    execute "ALTER TABLE `iterations` MODIFY `snippet` varchar(3100) NULL, ALGORITHM=INPLACE, LOCK=NONE"
    execute "ALTER TABLE `solutions` MODIFY `snippet` varchar(3100) NULL, ALGORITHM=INPLACE, LOCK=NONE"
  end

  def down
    # Shrinking a VARCHAR cannot run in place, so this copies the table.
    return if Rails.env.production?

    execute "ALTER TABLE `iterations` MODIFY `snippet` varchar(1500) NULL"
    execute "ALTER TABLE `solutions` MODIFY `snippet` varchar(1500) NULL"
  end
end
