FactoryGirl.define do
  factory :site1, class: Spree::Site do
    name 'first'
    email 'first@example.com'
    password 'password'
    short_name 'www' # indicate tld

    before(:create) do
      Spree::Role.find_by(name: 'admin') || create(:role, name: 'admin')
    end

    after(:create) do| site |
      store = create(:store, site: site, default: true )
    end

  end

  factory :site2, class: Spree::Site  do
    name 'design'
    email 'design@example.com'
    password 'password'

    before(:create) do
      Spree::Role.find_by(name: 'admin') || create(:role, name: 'admin')
    end

    after(:create) do| site |
      store = create(:store, site: site )
    end

  end


end
