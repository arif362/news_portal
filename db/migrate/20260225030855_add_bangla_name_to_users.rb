class AddBanglaNameToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :first_name_bn, :string
    add_column :users, :last_name_bn, :string
  end
end
