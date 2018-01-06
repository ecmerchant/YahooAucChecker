
require 'csv'

CSV.generate do |csv|
  csv_column_names = ["開催中のSKU"]
  csv << csv_column_names
  csv_column_names = %w(sku 現在価格 入札件数 残り時間)
  csv << csv_column_names
  if @products1 != nil then
    logger.debug("case 1")
    @products1.each do |product|
      resttime = product.rest
      resttime1 = (resttime).to_s + "分"
      if resttime >= 60 then
        resttime1 = (resttime / (60)).to_s + "時間"
      end
      if resttime >= 60*24 then
        resttime1 = (resttime / (60*24)).to_s + "日"
      end
      csv_column_values = [
        product.sku,
        product.cprice,
        product.bit,
        resttime1
      ]
      csv << csv_column_values
    end
  end
  csv_column_names = [nil]
  csv << csv_column_names
  ####
  csv_column_names = ["終了かつ入札ナシのSKU"]
  csv << csv_column_names
  csv_column_names = %w(sku 現在価格 入札件数 残り時間)
  csv << csv_column_names
  if @products2 != nil then
    logger.debug("case 2")
    @products2.each do |product|
      resttime = product.rest
      resttime1 = (resttime).to_s + "分"
      if resttime >= 60 then
        resttime1 = (resttime / (60)).to_s + "日"
      end
      if resttime >= 60*24 then
        resttime1 = (resttime / (60*24)).to_s + "日"
      end
      csv_column_values = [
        product.sku,
        product.cprice,
        product.bit,
        resttime1
      ]
      csv << csv_column_values
    end
  end
  csv_column_names = [nil]
  csv << csv_column_names
  ####
  csv_column_names = ["終了かつ落札済みのSKU"]
  csv << csv_column_names
  csv_column_names = %w(sku 現在価格 入札件数 残り時間)
  csv << csv_column_names
  if @products3 != nil then
    logger.debug("case 3")
    @products3.each do |product|
      resttime = product.rest
      resttime1 = (resttime).to_s + "分"
      if resttime >= 60 then
        resttime1 = (resttime / (60)).to_s + "日"
      end
      if resttime >= 60*24 then
        resttime1 = (resttime / (60*24)).to_s + "日"
      end
      csv_column_values = [
        product.sku,
        product.cprice,
        product.bit,
        resttime1
      ]
      csv << csv_column_values
    end
  end
end
