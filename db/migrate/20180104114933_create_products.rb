class CreateProducts < ActiveRecord::Migration[5.0]
  def change

    create_table :products do |t|
      t.string :user
      t.string :sku
      t.integer :cprice
      t.integer :bprice
      t.integer :bit
      t.integer :rest
      t.boolean :bitcheck
      t.boolean :restcheck

      t.timestamps
    end
  end
end
