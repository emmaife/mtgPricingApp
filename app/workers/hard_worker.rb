class HardWorker
  include Sidekiq::Worker

    def perform(*args)
        str = ""
        MagicCard.all.each do |x|
            str = str + x['productID'].to_s + ','
            if ERB::Util.url_encode(str).length >= 1500
                str = str[0...-1]
                url = URI("http://api.tcgplayer.com/pricing/product/" +  ERB::Util.url_encode(str))
                http = Net::HTTP.new(url.host, url.port)
                request = Net::HTTP::Get.new(url)
                request['Authorization'] = "Bearer 1OG2H2tTUKbtBOXa0hxEggt04PT2jBSvL6lELPAI499-Dj2UI9K7MnNAKRFstfdmertPNm84lqqRnn3t_7zwpS0yilsCMLAglh3Aui3PNVh8bBc0jAD7cfDC2_uI6gEMhoxdUKlzfcNcmGwk56_Cj5iYcNYAlDBwMqarMqPFmMsDYyVH8MjpH8l7aeDj0nXmJ4EfaOvCZARRQhVKvxOsHuqIWh9A-A-1p6joj8m6MRoTbZJROOAivaHe_Z27VTL-4pAd46J6Euxxyb7v1-hIM4b3K3A1Ml8KdY2JyebC063NF_sa97XFJOTbHzzyAkhMB3jzkPTNzdl1NrXObuNOJf4bajk"
                response = http.request(request)
                data = JSON.parse(response.body)
                data['results'].each do |x|
                    if x["subTypeName"] == "Normal"
                        c = MagicCard.find_by(productID: x['productId'])
                        c.update_attribute(:tcgPrice,  x["midPrice"])
                    elsif x["subTypeName"] == "Foil"
                        if MagicCard.where(productID: -(x['productId'])).exists?
                            c = MagicCard.find_by(productID: -(x['productId']))
                            c.update_attribute(:tcgPrice,  x["midPrice"])
                        else
                            MagicCard.create(:productID => -(x['productId']), :tcgPrice => x["midPrice"] )
                        end
                    end
                end
                str = ""
            end
        end
        MagicCard.where("id > ?", 0).all.each do |x|
            setCode = x["set"]
            set = MagicSet.find_by(tcgID: setCode)
            unless set.nil?
                ckCode = MagicSet.find_by(tcgID: setCode)["ckID"]
                cardName = x["name"]
                scraper = Mechanize.new
                scraper.history_added = Proc.new { sleep 0.5 }
                sleep 0.5

                scraper.get('https://www.cardkingdom.com/purchasing/mtg_singles?filter[sort]=price_desc&filter[search]=mtg_advanced') do |search_page|
                    form = search_page.form_with(:id => 'search') do |search|    
                        search['filter[name]'] = cardName
                        search['filter[category_id]'] = ckCode
                    end
                    result_page = form.submit
                    raw_results = result_page.search('div.itemContentWrapper')
                    raw_results.each do |result|
                        unless result.css('span.sellDollarAmount')[0].nil?
                            newCardName =  result.css('span.productDetailTitle').text.strip
                            foil =  result.css('div.foil').text.strip
                            price = result.css('span.sellDollarAmount')[0].text.strip + '.' + result.css('span.sellCentsAmount')[0].text.strip
                            price = price.to_f
                            if foil != "FOIL"
                                x.update_attribute(:ckPrice, price  ) 
                                unless x["tcgPrice"].nil?
                                    spread =  ((1 - (price/x["tcgPrice"]))*100)
                                    x.update_attribute(:spread, spread  ) 
                                end
                          
                            else
                                f = MagicCard.find_by(productID: -(x['productID']))
                                f.update_attribute(:ckPrice, price ) 
                                unless f["tcgPrice"].nil?
                                    spread =  ((1 - (price/f["tcgPrice"]))*100)
                                    f.update_attribute(:spread, spread  ) 
                                end
                            end
                        end
                    end
                end
            end
        end
    end
end


    