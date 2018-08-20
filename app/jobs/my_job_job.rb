class MyJobJob < ApplicationJob

  queue_as :default
  require 'typhoeus'
  require 'objspace'

  def perform(tag, cuser)
    # Do something later
    logger.debug("Process Start")
    ua = CSV.read('app/others/User-Agent.csv', headers: false, col_sep: "\t")
    cv = Product.where(user: cuser)
    temp = User.find_by(email:cuser)
    logger.debug(temp.conved)
    jd = temp.conved
    uanum = ua.length
    user_agent = ua[rand(uanum)][0]
    
    tag.each do |sku|
      if jd == true then
        tt = cv.find_by(sku: sku)
        tsku = tt.code
        sku = tsku
      end

      url = 'https://page.auctions.yahoo.co.jp/jp/auction/' + sku
      logger.debug(url)
      
      charset = nil
      #rt = rand(10)*0.1+0.2
      #sleep(rt)
      begin

        #html = open(url, "User-Agent" => user_agent) do |f|
        #html = open(url) do |f|
        #  charset = f.charset # 文字種別を取得
        #  f.read # htmlを読み込んで変数htmlに渡す
        #end

        #typhoeusをテスト
        logger.debug("Access URL")
        request = Typhoeus::Request.new(
          url,
          headers: {'User-Agent': user_agent}
        )
        request.run
        html = request.response.body

        doc = Nokogiri::HTML.parse(html, nil, charset)
        auction = doc.xpath('//p[@class="ptsFin"]')[0] #オークションが終了かチェック
        logger.debug("Get Html body")
        if auction == nil then
          logger.debug('Item is on sale')
          title = doc.xpath('//h1[@class="ProductTitle__text"]')[0].inner_text
          tc = doc.xpath('//div[@class="Price Price--current"]')[0]

          if tc != nil then
            cPrice = tc.xpath('dl/dd[@class="Price__value"]/text()')[0]
            cPrice = cPrice.inner_text.gsub(/\,/,"").gsub(/円/,"").gsub(/ /,"").to_i
          else
            cPrice = 0
          end

          tb = doc.xpath('//div[@class="Price Price--buynow"]')[0]
          if tb != nil then
            bPrice = tb.xpath('dl/dd[@class="Price__value"]/text()')[0]
            bPrice = bPrice.inner_text.gsub(/\,/,"").gsub(/円/,"").gsub(/ /,"").to_i
          else
            bPrice = 0
          end

          bit = doc.xpath('//li[@class="Count__count"]')[0]
          if bit != nil then
            bit = bit.xpath('dl/dd[@class="Count__number"]')[0].inner_text.to_i
          else
            bit = 0
          end

          rest = doc.xpath('//li[@class="Count__count Count__count--sideLine"]')[0]
          if rest != nil then
            restunit = rest.xpath('dl/dd[@class="Count__number"]/span[@class="Count__unit"]')[0].inner_text
            rest = rest.xpath('dl/dd[@class="Count__number"]/text()')[0].inner_text

            case restunit
            when "日" then
              rest = rest.to_i * 60 * 24
            when "時間" then
              rest = rest.to_i * 60
            when "分" then
              rest = rest.to_i
            else
              rest = 0
            end
          else
            rest = 0
          end

          if bit == 0 then
            bcheck = true
          else
            bcheck = false
          end

          if rest != 0 then
            rcheck = true
          else
            rcheck = false
          end

        else #オークションが終了の場合
          logger.debug("Auction is end")
          cPrice = doc.xpath('//tr[@class="elAucPriceRw"]')[0]
          if cPrice != nil then
            taxin = cPrice.xpath('//p[@class="decTxtTaxIncPrice"]')[0].inner_text
            if taxin == '（税0円）'  then
              cPrice = cPrice.xpath('//p[@class="decTxtAucPrice"]')[0].inner_text
              cPrice = cPrice.gsub(/\,/,"").gsub(/円/,"").gsub(/ /,"").to_i
            else
              cPrice = cPrice.xpath('//p[@class="decTxtAucPrice"]')[0].inner_text
              cPrice = cPrice[3..(cPrice.length-2)]
              cPrice = cPrice.gsub(/\,/,"").gsub(/円/,"").gsub(/ /,"").to_i
            end
          else
            cPrice = 0
          end

          bPrice = doc.xpath('//tr[@class="elBidOrBuyPriceRw"]')[0]
          if bPrice != nil then
            taxin = bPrice.xpath('//p[@class="decTxtTaxIncPrice"]')[0].inner_text
            if taxin == '（税0円）'  then
              bPrice = bPrice.xpath('//p[@class="decTxtBuyPrice"]')[0].inner_text
              bPrice = bPrice.gsub(/\,/,"").gsub(/円/,"").gsub(/ /,"").to_i
            else
              bPrice = bPrice.xpath('//p[@class="decTxtBuyPrice"]')[0].inner_text
              bPrice = bPrice[3..(bPrice.length-2)]
              bPrice = bPrice.gsub(/\,/,"").gsub(/円/,"").gsub(/ /,"").to_i
            end
          else
            bPrice = 0
          end

          bit = doc.xpath('//b[@property="auction:Bids"]')[0].inner_text.to_i
          rest = 0
          if bit == 0 then
            bcheck = true
          else
            bcheck = false
          end
          rcheck = false
        end

      rescue => e
        logger.debug("Error!!\n")
        logger.debug(e)

        cPrice = 0
        bPrice = 0
        bit = 0
        rest = 0
        bcheck = false
        rcheck = false
      end
      logger.debug('Start updating table')
      #Product.find_by(user: cuser, sku: sku).update(
      #  cprice: cPrice,
      #  bprice: bPrice,
      #  bit: bit,
      #  rest: rest,
      #  bitcheck: bcheck,
      #  restcheck: rcheck,
      #  end_flg: true
      #)
      cv.update(
        sku: sku,
        cprice: cPrice,
        bprice: bPrice,
        bit: bit,
        rest: rest,
        bitcheck: bcheck,
        restcheck: rcheck,
        end_flg: true
      )

      ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
      GC.start
      logger.debug('Process end')
    end
  end
end
