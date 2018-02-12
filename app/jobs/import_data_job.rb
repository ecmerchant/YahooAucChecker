class ImportDataJob < ApplicationJob
  queue_as :default
  require 'csv'

  def perform(csv, user)
    # Do something later
    for row in csv do
      sku = row.to_s
      sku.gsub!(" ", "")
      sku.gsub!("\n", "")
      sku.gsub!("\r", "")
      sku.gsub!("\t", "")
      Product.create(
        user: user,
        sku: sku,
        bitcheck: false,
        restcheck: false,
        end_flg: false
      )
    end
  end
end
