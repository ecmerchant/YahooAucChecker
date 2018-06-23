class AddConvedToUsers < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :conved, :boolean
  end
end
