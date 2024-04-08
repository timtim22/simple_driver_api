class CreateBlobs < ActiveRecord::Migration[7.0]
  def change
    create_table :blobs, id: :string, force: :cascad do |t|
      t.text :data
      t.integer :size

      t.timestamps
    end
  end
end
