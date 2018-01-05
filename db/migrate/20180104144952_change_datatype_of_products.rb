class ChangeDatatypeOfProducts < ActiveRecord::Migration[5.0]
  #変更後の型
  def up
    change_column :Products, :restcheck, :boolean, null: :false, default: :false
    change_column :Products, :bitcheck, :boolean, null: :false, default: :false
  end

  #変更前の型
  def down
    change_column :Products, :restcheck, :boolean
    change_column :Products, :bitcheck, :boolean
  end
end
