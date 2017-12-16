Spree::Taxon.class_eval do
  has_many :post_classifications, dependent: :delete_all, inverse_of: :post
  has_many :posts, through: :post_classifications
end
