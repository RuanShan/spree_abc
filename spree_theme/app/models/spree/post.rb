module Spree
  class Post < ActiveRecord::Base
    #attr_accessible :title, :cover, :teaser, :body, :posted_at, :author, :live, :tag_list, :taxon_ids, :product_ids_string
    extend FriendlyId
    friendly_id :slug_candidates, :use => :slugged

    acts_as_taggable
    # for flash messages
    alias_attribute :name, :title

    has_many :post_classifications, dependent: :delete_all, inverse_of: :post
    has_many :taxons, through: :post_classifications
    #has_and_belongs_to_many :taxons, :join_table => "spree_posts_taxons", :class_name => "Spree::Taxon"
    alias_attribute :categories, :taxons

    #belongs_to :blog, :class_name => "Spree::Taxon"
    #has_many :taxons, :dependent => :destroy
    has_many :products, :through => :post_products
    has_many :files, :as => :viewable, :class_name => "Spree::PostFile", :dependent => :destroy

    #validates :blog_id, :title, :presence => true
    #validates :permalink,  :presence => true, :uniqueness =>{ :scope=>:site_id }, :if => proc{ |record| !record.title.blank? }
    validates :slug, length: { minimum: 3 }

    validates :body,  :presence => true
    validates :posted_at, :datetime => true

    #has_attached_file :cover,
    #  styles: { small: '180x120>', normal: '280x190>', big: '670x370>'},
    #  default_style: :normal,
    #  url: '/spree/posts/:id/:style/:basename.:extension',
    #  path: ':rails_root/public/spree/posts/:id/:style/:basename.:extension',
    #  default_url: '/assets/default_post.png'
    has_attached_file :cover,
      styles: { :mini => '60x60>', small: '180x120>', medium: '280x190>', large: '670x370>'},
      default_style: :mini,
      url: '/shops/:rails_env/:site/posts/:id/:basename_:style.:extension',
      path: ':rails_root/public/shops/:rails_env/:site/posts/:id/:basename_:style.:extension',
      default_url: '/assets/default_post.png'

    validates_attachment :cover,
      content_type: { content_type: ["image/jpg", "image/jpeg", "image/png", "image/gif"] }

    scope :ordered, -> { order("posted_at DESC") }
    scope :future, -> { where("posted_at > ?", Time.now).order("posted_at ASC") }
    scope :past, -> { where("posted_at <= ?", Time.now).ordered }
    scope :live, -> {  where(:live => true ) }

   	#make_permalink

    # add search related
    cattr_accessor :searcher_class do
      SpreeTheme::BlogSearch
    end

    cattr_accessor :search_scopes do
      []
    end

    def self.add_search_scope(name, &block)
      self.singleton_class.send(:define_method, name.to_sym, &block)
      search_scopes << name.to_sym
    end
    #copy from spree/core/model/product/scope
    add_search_scope :in_taxon do |taxon|
      select("spree_posts.id, spree_posts.*").
      where(id: PostClassification.select('spree_posts_taxons.post_id').
            joins(:taxon).
            where( Taxon.table_name => { :id => taxon.self_and_descendants.pluck(:id) })
           )
    end
    # end search

    # Creates date-part accessors for the posted_at timestamp for grouping purposes.
    %w(day month year).each do |method|
      define_method method do
        self.posted_at.send(method)
      end
    end

    # all post belongs to taxon which context is blog, in this way, we cuold list all post of website. ex. page blogs list recent posts
    def taxon

    end

    alias_method :blog, :taxon

    def summary( truncate_at=100)
      #copy from Action View Sanitize Helpers
      Rails::Html::FullSanitizer.new.sanitize( body ).truncate( truncate_at )
    end

  	def rendered_preview
      preview = body.split("<!-- more -->")[0]
      render(preview)
    end

  	def rendered_body
  	  render(body.gsub("<!-- more -->", ""))
    end

  	def preview_image
      images.first if has_images?
  	end

    def has_images?
      images && !images.empty?
    end


    def live?
      live && live == true
    end

    def product_ids_string
      product_ids.join(',')
    end

    def product_ids_string=(s)
      self.product_ids = s.to_s.split(',').map(&:strip)
    end

    def to_param
      slug
    end

    def slug_candidates
        [
          :title_to_url,
          [:title_to_url, :site_id],
        ]
    end

    # make title as slug candidate,
    # "女性穿内衣的6大误区".to_url => "nu-xing-chuan-nei-yi-de-6da-wu-qu"
    def title_to_url
      title.to_url
    end

  end

end
