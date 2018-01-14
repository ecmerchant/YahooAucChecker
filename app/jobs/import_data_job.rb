class ImportDataJob < ApplicationJob
  queue_as :default
  require 'csv'

  def perform(csv, user)
    # Do something later
    if csv.headers.include?(:sku) then
      logger.debug("sku header")
      for row in csv[:sku] do
        Product.create(
          user: user,
          sku: row,
          bitcheck: false,
          restcheck: false,
          end_flg: false
        )
      end
    else
      logger.debug("no header")
    end
  end
end
