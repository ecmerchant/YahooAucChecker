class Product < ApplicationRecord

  require 'nokogiri'
  require 'open-uri'

  def inventory(tag)
    cuser = user
    ua = CSV.read('app/others/User-Agent.csv', headers: false, col_sep: "\t")

    tag.each do |sku|
      url = 'https://page.auctions.yahoo.co.jp/jp/auction/' + sku
      logger.debug(url)
      uanum = ua.length
      user_agent = ua[rand(uanum)][0]
      charset = nil
      #rt = rand(10)*0.1+0.2
      rt = rand(10)*0.1+0.2
      sleep(rt)
      begin
        html = open(url, "User-Agent" => user_agent) do |f|
        #html = open(url) do |f|
          charset = f.charset # 文字種別を取得
          f.read # htmlを読み込んで変数htmlに渡す
        end

        doc = Nokogiri::HTML.parse(html, nil, charset)
        auction = doc.xpath('//p[@class="ptsFin"]')[0] #オークションが終了かチェック

        if auction == nil then
          logger.debug('success')
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
          logger.debug("auction is end")
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
          logger.debug("check1")
          bPrice = doc.xpath('//tr[@class="elBidOrBuyPriceRw"]')[0]
          if bPrice != nil then
            taxin = bPrice.xpath('//p[@class="decTxtTaxIncPrice"]')[0].inner_text
            logger.debug("check2")
            logger.debug(taxin)
            if taxin == '（税0円）'  then
              bPrice = bPrice.xpath('//p[@class="decTxtBuyPrice"]')[0].inner_text
              logger.debug("check3")
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
          logger.debug("check3")
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

      Product.find_by(user: cuser, sku: sku).update(
        cprice: cPrice,
        bprice: bPrice,
        bit: bit,
        rest: rest,
        bitcheck: bcheck,
        restcheck: rcheck
      )
    end
  end

end
