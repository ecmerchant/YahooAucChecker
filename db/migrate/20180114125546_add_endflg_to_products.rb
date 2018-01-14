class AddEndflgToProducts < ActiveRecord::Migration[5.0]
  def change
    add_column :products, :end_flg, :boolean
  end
end
