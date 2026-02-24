class CreateArticles < ActiveRecord::Migration[8.1]
  def change
    create_table :articles, id: :uuid do |t|
      t.string :title, null: false
      t.string :slug, null: false
      t.text :excerpt
      t.integer :status, null: false, default: 0
      t.references :category, type: :uuid, foreign_key: true, null: false
      t.references :author, type: :uuid, foreign_key: { to_table: :users }, null: false
      t.datetime :published_at
      t.boolean :featured, null: false, default: false
      t.boolean :breaking, null: false, default: false
      t.integer :views_count, null: false, default: 0
      t.boolean :comments_enabled, null: false, default: true
      t.string :meta_title
      t.string :meta_description
      t.string :meta_keywords

      t.timestamps
    end

    add_index :articles, :slug, unique: true
    add_index :articles, :status
    add_index :articles, :published_at
    add_index :articles, :featured
    add_index :articles, :breaking
    add_index :articles, [ :status, :published_at ]
    add_index :articles, [ :category_id, :status ]
    add_index :articles, [ :author_id, :status ]
    add_index :articles, :views_count
  end
end
