class CreatePages < ActiveRecord::Migration[8.1]
  def change
    create_table :pages, id: :uuid do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.integer :status, null: false, default: 0
      t.integer :position, null: false, default: 0
      t.boolean :show_in_navigation, null: false, default: false
      t.string :meta_title
      t.string :meta_description
      t.references :author, type: :uuid, foreign_key: { to_table: :users }, null: false

      t.timestamps
    end

    add_index :pages, :slug, unique: true
    add_index :pages, :status
    add_index :pages, [ :show_in_navigation, :position ]
  end
end
