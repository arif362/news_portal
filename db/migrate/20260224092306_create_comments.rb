class CreateComments < ActiveRecord::Migration[8.1]
  def change
    create_table :comments, id: :uuid do |t|
      t.text :body, null: false
      t.references :article, type: :uuid, foreign_key: true, null: false
      t.references :user, type: :uuid, foreign_key: true, null: false
      t.references :parent, type: :uuid, foreign_key: { to_table: :comments }, null: true
      t.integer :status, null: false, default: 0
      t.string :ip_address

      t.timestamps
    end

    add_index :comments, :status
    add_index :comments, [ :article_id, :status ]
    add_index :comments, [ :user_id, :created_at ]
  end
end
