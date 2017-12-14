#encoding:utf-8
module SpreeMoneyCNY
    # fix price.to_html =>元 12.00   ¥12.00
    # fix price.to_html =>¥12.00 CNY ¥12.00
    def to_html(options = { :html => true })
      options.merge! :with_currency => false, :symbol=>true
      super
    end
end

Spree::Money.prepend( SpreeMoneyCNY )
