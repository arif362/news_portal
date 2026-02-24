class CreateArticleTags < ActiveRecord::Migration[8.1]
  def change
    create_table :article_tags, id: :uuid do |t|
      t.references :article, type: :uuid, foreign_key: true, null: false
      t.references :tag, type: :uuid, foreign_key: true, null: false

      t.timestamps
    end

    add_index :article_tags, [ :article_id, :tag_id ], unique: true
  end
end
