# order model by alphabet

Spree::Asset.class_eval do
  include Spree::MultiSiteSystem
end

#Spree::Configuration.class_eval do
#  belongs_to :site
#  default_scope  { where(:site_id =>  Spree::Site.current.id) }
#end

Spree::LogEntry.class_eval do
  belongs_to :site
  default_scope  { where(:site_id =>  Spree::Site.current.id) }
end

Spree::OptionType.class_eval do
  belongs_to :site
  default_scope  { where(:site_id =>  Spree::Site.current.id) }
  clear_validators!
  # Add new validates_uniqueness_of with correct scope
  validates :name, :uniqueness => { :scope => [:site_id] }

end

Spree::Order.class_eval do
  include Spree::MultiSiteSystem
end

# we should never call LineItem.find or LineItem.new
# use @order.line_items, @order.add_variant instead

Spree::Prototype.class_eval do
  include Spree::MultiSiteSystem
end

#保存对应每个Site的配置属性
Spree::Preference.class_eval do
  include Spree::MultiSiteSystem
end

Spree::PaymentMethod.class_eval do
  include Spree::MultiSiteSystem
end

Spree::Product.class_eval do
  include Spree::MultiSiteSystem
  include Spree::ProductExtraScope

  #has_many :global_classifications, dependent: :delete_all
  #has_many :global_taxons, through: :global_classifications, source: :taxon


  # Try building a slug based on the following fields in increasing order of specificity.
  def slug_candidates
    [
      :name_to_url,
      [:name_to_url, :sku],
      [:name_to_url, :sku, :site_id]
    ]
  end

  def name_to_url
    name.to_url
  end
end

Spree::Property.class_eval do
  include Spree::MultiSiteSystem
end

#TODO add site_id into shipments?

Spree::ShippingCategory.class_eval do
  include Spree::MultiSiteSystem
  clear_validators!
  # comment when rake test_app
  #validates :name, presence: true, uniqueness: { allow_blank: true, scope: :site_id }
end

Spree::ShippingMethod.class_eval do
  include Spree::MultiSiteSystem

end


Spree::Taxonomy.class_eval do
  include Spree::MultiSiteSystem
end


Spree::Taxon.class_eval do
  include Spree::MultiSiteSystem

  has_many :global_classifications, dependent: :delete_all
  has_many :global_products, through: :global_classifications, source: :product

end

Spree::TaxCategory.class_eval do

  belongs_to :site
  default_scope  { where(:site_id =>  Spree::Site.current.id) }

  clear_validators!
  # Add new validates_uniqueness_of with correct scope
  validates :name, :uniqueness => { scope: [:site_id,:deleted_at], allow_blank: true }

end

# TaxRate is join table, include tax_catory_id and zone_id
# in TaxRate.match it called method :all, so we have to add joins=>tax_category
# in fact, we should never use TaxRate in spree_abc for now.
Spree::TaxRate.class_eval do
  default_scope { joins( :tax_category). where("spree_tax_categories.site_id=?", Spree::Site.current.id) }
end

Spree::Tracker.class_eval do
  include Spree::MultiSiteSystem

  def self.current
    tracker = where(active: true).first
    tracker.analytics_id.present? ? tracker : nil if tracker
  end
end

Spree.user_class.class_eval do
  # user.email validation is unique, it is defined in devise/lib/models/validatable.rb
  # 1. we required user have unique email,
  # 2. we allow user modify their password after sign up.
  # fix unique with scope [site_id] would conflict with 1
  include Spree::MultiSiteSystem
end

Spree::Variant.class_eval do
  clear_validators!
  # copy original validates
  #validate :check_price

  validates :cost_price, numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  validates :price,      numericality: { greater_than_or_equal_to: 0, allow_nil: true }
  # disable uniqueness_of :sku
  validates_uniqueness_of :sku, allow_blank: true, conditions: -> { joins(:product).where( spree_variants: { deleted_at: nil}, spree_products: {site_id: Spree::Site.current.id } ) }

end

Spree::Zone.class_eval do
  include Spree::MultiSiteSystem

  clear_validators!
  # Add new validates_uniqueness_of with correct scope
  validates :name, :presence => true, :uniqueness => { :scope => [:site_id] }
end


Spree::Post.class_eval do
  belongs_to :site
  default_scope  { where(:site_id =>  Spree::Site.current.id) }
end
