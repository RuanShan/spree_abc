payment_method = Spree::PaymentMethod.where(:name => 'Alipay', :active => true).first
payment_method.preferred_email = 'areq_22@yahoo.com.cn'
payment_method.preferred_partner = '2088002627298374'
payment_method.preferred_sign = 'f4y25qc539qakg734vn2jpqq6gmybxoz'
payment_method.save!
