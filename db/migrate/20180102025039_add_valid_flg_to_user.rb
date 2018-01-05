class AddValidFlgToUser < ActiveRecord::Migration[5.0]
  def change
    add_column :users, :valid_flg, :boolean
  end
end
