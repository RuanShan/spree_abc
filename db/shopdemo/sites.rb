attributes = {  
    :name =>  "Dalianshops demo",
    :domain => "demo.dalianshops.com",
    :short_name => "demo",
    :email => "demo@dalianshops.com",
    :password =>'spree123'
  }
site = Spree::Site.create!(attributes) 
   
Spree::Site.current = site

