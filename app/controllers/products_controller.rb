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

      if @res2.first.updated_at.in_time_zone('Tokyo') == @res2.first.created_at.in_time_zone('Tokyo') then
        @fntime = "処理前"
      else
        total = @res2.count.to_s
        temp = @res2.where(end_flg: true).count.to_s
        @fntime = "処理中 " + temp + "/" + total + "件"
      end
      temp = @res2.order(id: :desc)

      if temp.first.end_flg then
        @fntime = @res2.last.updated_at.in_time_zone('Tokyo')
      end
    end

    if request.post? then
      data = @res2.pluck(:sku)
=begin
      logger.debug("======01=======")
      logger.debug(Resque.size(:test_01))
      status = Resque.size(:test_01)
      if status > 0 then
        logger.debug("====== Already Queued =======")
      else
        logger.debug("====== Start =======")
        #MyJobJob.set(queue: :test_01).perform_later(data, current_user.email)
        MyJobJob.perform_later(data, current_user.email)
      end
      logger.debug("======00=======")
      logger.debug(Resque.size(:test_01))
=end
      MyJobJob.perform_later(data, current_user.email)
      sleep(0.5)
      redirect_to products_sort_path
    end

  end


  def import
    csvfile = params[:file]
    check = Product.where(user: current_user.email)
    if check != nil then
      check.delete_all
    end
    #Product.destroy_all(user: current_user.email)
    if csvfile != nil then
      csv = CSV.table(csvfile.path)
      if csv.headers.include?(:sku) then
        logger.debug("sku header")
        td = csv[:sku]
        ImportDataJob.perform_later(td,current_user.email)
      end
    end
    redirect_to root_path
  end

  def setup
    @user = current_user.email
    @users = User.find_by(email: @user)
    @products = Product.where(user: current_user.email)
    if request.post? then
      @users.update(user_params)
    end
  end

  def export
    @products1 = Product.where(user: current_user.email).where(restcheck: true).where(end_flg: true)
    @products2 = Product.where(user: current_user.email).where(restcheck: false).where(bitcheck: true).where(end_flg: true)
    @products3 = Product.where(user: current_user.email).where(restcheck: false).where(bitcheck: false).where(end_flg: true)
    fname = "在庫結果_" + (DateTime.now.strftime("%Y%m%d%H%M")) + ".csv"
    send_data render_to_string, filename: fname, type: :csv
  end

  def converse
    csvfile = params[:file]
    products = Product.where(user: current_user.email)
    if csvfile != nil then
      csv = CSV.read(csvfile.path)
      CSV.foreach(csvfile.path) do |row|
        logger.debug("sku:" + row[0].to_s)
        logger.debug("code:" + row[1].to_s)
        temp = products.find_by(sku: row[0])
        if temp != nil then
          temp.update(code:row[1].to_s)
        end
      end
    end

    redirect_to products_setup_path
  end

  private
  def user_params
     params.require(:user).permit(:conved)
  end

end
