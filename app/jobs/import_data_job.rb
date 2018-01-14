class ImportDataJob < ApplicationJob
  queue_as :default
  require 'csv'

  def perform(csv, user)
    # Do something later
    for row in csv do
      Product.create(
        user: user,
        sku: row,
        bitcheck: false,
        restcheck: false,
        end_flg: false
      )
    end
  end
end
