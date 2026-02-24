class CreateUsers < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.string :email, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :username, null: false
      t.integer :role, null: false, default: 0
      t.text :bio
      t.string :password_reset_token
      t.datetime :password_reset_sent_at
      t.datetime :last_sign_in_at
      t.string :last_sign_in_ip
      t.integer :sign_in_count, null: false, default: 0
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :username, unique: true
    add_index :users, :role
    add_index :users, :password_reset_token, unique: true
    add_index :users, :active
  end
end
