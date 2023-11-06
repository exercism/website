class CreateAddUuidToCodeTagsSamples < ActiveRecord::Migration[7.0]
  def change
    create_table :add_uuid_to_code_tags_samples do |t|

      t.timestamps
    end
  end
end
