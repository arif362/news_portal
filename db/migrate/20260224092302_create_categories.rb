class CreateCategories < ActiveRecord::Migration[8.1]
  def change
    create_table :categories, id: :uuid do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.references :parent, type: :uuid, foreign_key: { to_table: :categories }, null: true
      t.integer :position, null: false, default: 0
      t.boolean :active, null: false, default: true
      t.string :meta_title
      t.string :meta_description

      t.timestamps
    end

    add_index :categories, :slug, unique: true
    add_index :categories, :position
    add_index :categories, :active
    add_index :categories, :name
  end
end
