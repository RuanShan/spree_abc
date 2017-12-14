module Spree
  module Admin
    class SitesController< Spree::Admin::ResourceController
      before_action :ensure_access_allowed
      #resource_controller
      self.create.after( :create_after )

      def index
        @sites = Site.ransack(params[:q]).result.page(params[:page]).per(params[:per_page])
      end

      def new
        @user = @site.users.build
        super
      end

      def create
        @user = Spree.user_class.new(params[:user])
        @site.users << @user
        super
      end

      def create_after
        @site.users.first.roles << Role.find_by_name("admin")
        # should not add  @site.name as suffix of role.name, User.admin require :name="admin"
        if @site.has_sample?
          @site.load_sample
          #@site.update_attributes!(:loading_sample=>true)
          # add job to load sample
          #Delayed::Job.enqueue SampleSeedJob.new( @site )
        end
      end

      private
      def ensure_access_allowed
        unless Spree::Store.current.god?
          raise CanCan::AccessDenied.new("Not authorized!", :access, Site)
          #redirect_to Spree::Site.current.admin_url
        end
      end
    end
  end
end
