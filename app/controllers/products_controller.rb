class ProductsController < ApplicationController

  require 'nokogiri'
  require 'open-uri'
  require 'uri'
  require 'csv'

  before_action :authenticate_user!

  rescue_from CanCan::AccessDenied do |exception|
    redirect_to root_url, :alert => exception.message
  end


  def sort
    @user = current_user.email
    @res2 = Product.where(user: current_user.email)
    if @res2[0] != nil then
      @sttime = @res2.first.updated_at.in_time_zone('Tokyo')
      @fntime = @res2.last.updated_at.in_time_zone('Tokyo')
      if @fntime - @sttime < 3 then
        @fntime = nil
      end
      if @res2.first.id == @res2.last.id then
        @fntime = @res2.last.updated_at.in_time_zone('Tokyo')
      end
      if @res2.last.created_at == @res2.last.updated_at then
        if @res2.first.created_at != @res2.first.updated_at then
          @fntime = "処理中"
        end
      end
    end

    if request.post? then
      data = @res2.pluck(:sku)
      target = Product.find_by(user: current_user.email)
      #target.delay.inventory(data)
      target.inventory(data)
      sleep(0.5)
      redirect_to products_sort_path
    end

  end


  def import
    csvfile = params[:file]
    Product.destroy_all(user: current_user.email)
    if csvfile != nil then
      csv = CSV.table(csvfile.path)
      logger.debug(csv.headers)
      if csv.headers.include?(:sku) then
        logger.debug("sku header")
        for row in csv[:sku] do
          Product.create(
            user: current_user.email,
            sku: row,
            bitcheck: false,
            restcheck: false
          )
        end
      else
        logger.debug("no header")
      end
      #@res = csv
    end
    redirect_to root_path
  end

  def export
    @products1 = Product.where(user: current_user.email).where(restcheck: true)
    @products2 = Product.where(user: current_user.email).where(restcheck: false).where(bitcheck: true)
    @products3 = Product.where(user: current_user.email).where(restcheck: false).where(bitcheck: false)
    fname = "在庫結果_" + (DateTime.now.strftime("%Y%m%d%H%M")) + ".csv"
    send_data render_to_string, filename: fname, type: :csv
  end

end
