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
      if @res2.last.end_flg == false then
        if @res2.first.updated_at.in_time_zone('Tokyo') == @res2.first.created_at.in_time_zone('Tokyo') then
          @fntime = "処理前"
        else
          total = Product.where(user: current_user.email).count.to_s
          temp = Product.where(user: current_user.email).where(end_flg: true).count.to_s
          @fntime = "処理中 " + temp + "/" + total + "件" 
        end
      else
        @fntime = @res2.last.updated_at.in_time_zone('Tokyo')
      end
    end

    if request.post? then
      data = @res2.pluck(:sku)
      target = Product.find_by(user: current_user.email)
      #target.delay.inventory(data)
      #target.inventory(data)
      MyJobJob.perform_later(data,current_user.email)
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
            restcheck: false,
            end_flg: false
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
