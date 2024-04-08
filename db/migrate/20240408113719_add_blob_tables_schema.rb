class AddBlobTablesSchema < ActiveRecord::Migration[7.0]
  def change

    create_table :blobs, id: :string do |t|
      t.integer :size
      t.string :storage_backend
      t.string :path
      t.timestamps
    end

    create_table :blob_data do |t|
      t.string :blob_id, null: false
      t.text :data
      t.timestamps
    end

    add_foreign_key :blob_data, :blobs, column: :blob_id, primary_key: :id, on_delete: :cascade
  end
end
