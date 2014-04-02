module Spree
    class SitesController< StoreController
      def new
        if request.get?
          @site = Site.new
          @user = @site.users.build
        else
          @site = Site.new(params[:site])
          @user = Spree.user_class.new(params[:user])
          @site.users << @user
          if @site.save
            @site.users.first.spree_roles << Spree::Role.find_by_name('admin')
            # should not add  @site.name as suffix of role.name, User.admin require :name="admin"
            if @site.has_sample?
              @site.load_sample
              #@site.update_attributes!(:loading_sample=>true)
              # add job to load sample
              #Delayed::Job.enqueue SampleSeedJob.new( @site )
            end 
            redirect_to site_path(@site)
          end
        end
      end
      
      def quick_lunch
          @site = Site.new(params[:site])          
          if params[:user]
            params[:user][:password_confirmation] = params[:user][:password] 
          end
          @user = Spree.user_class.new(params[:user])
          @site.users << @user
          if @site.save
            @site.users.first.spree_roles << Spree::Role.find_by_name('admin')
            redirect_to @site.admin_url
          else
            redirect_to root_path()            
          end        
      end
      
      def show
        @site = Site.find(params[:id])
        render :after_new
      end
           
    end
  
end