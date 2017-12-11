def rename_multi_site_migrations
  puts "calling spree_multi_site:install:migrations enhance"
  # default migration sequence is spree's migration -> extension's migration
  # we need to create site first, or User.find will cause error, so change name to reset order
  #
  # 1create_site ->
  # -> spree_zero_nine_zero -> other_spree_multi_site_migrations
  spree_zero_nine_zero_migration = nil
  special_migration_regex = /create_sites/
    #add_site_orders|
    #add_short_name_and_parent_id_to_site|
    #add_has_sample|
    #add_site_taxons/
  spree_multi_site_migrations = []
  Dir[File.join(Rails.root,'db','migrate','*.rb')].sort.each{|file|
    spree_zero_nine_zero_migration = file if file =~/spree_one_two/
    spree_multi_site_migrations<< file if file=~/spree_multi_site.rb$/ && file =~special_migration_regex #z: load it at last.
    #leave this file 'add_site_payment_methods' at the end
  }
  #puts "--spree_zero_nine_zero_migration=#{spree_zero_nine_zero_migration}"
  #puts "--spree_multi_site_migrations=#{spree_multi_site_migrations}"
  if spree_zero_nine_zero_migration.present? && spree_multi_site_migrations.present?
    spree_zero_file_name = File.basename(spree_zero_nine_zero_migration,'.rb') # spree_zero_nine_zero_migration is full path
    migration_start_number =  spree_zero_file_name.to_i - spree_multi_site_migrations.size
    create_site_migration = spree_multi_site_migrations.shift
    create_site_file_name = File.basename(create_site_migration,'.rb')
    #puts "spree_zero_file_name=#{spree_zero_file_name}, create_site_file_name=#{create_site_file_name}"
    if spree_zero_file_name.to_i < create_site_file_name.to_i #reorder
      File.rename(create_site_migration, create_site_migration.sub(/\d+/, migration_start_number.to_s))
      File.rename(spree_zero_nine_zero_migration, spree_zero_nine_zero_migration.sub(/\d+/,(migration_start_number+1).to_s))
      spree_multi_site_migrations.each_index{|i|
        migration_file = spree_multi_site_migrations[i]
        File.rename(migration_file, migration_file.sub(/\d+/,(migration_start_number+2+i).to_s))
      }
    end
  end
  puts "complete renaming spree_multi_site's migration"

end

# task test_app call railties:install:migrations
Rake::Task['railties:install:migrations'].enhance do
  rename_multi_site_migrations
end

#namespace :spree_multi_site do
#  namespace :install do
#    namespace :migrations do
#    end
#  end
#end

namespace :spree do
  namespace :extensions do
    namespace :multi_site do
      desc "Copies public assets of the Multi Site to the instance public/ directory."
      task :update => :environment do
        is_svn_git_or_dir = proc {|path| path =~ /\.svn/ || path =~ /\.git/ || File.directory?(path) }
        Dir[MultiSiteExtension.root + "/public/**/*"].reject(&is_svn_git_or_dir).each do |file|
          path = file.sub(MultiSiteExtension.root, '')
          directory = File.dirname(path)
          puts "Copying #{path}..."
          mkdir_p RAILS_ROOT + directory
          cp file, RAILS_ROOT + path
        end
      end
      desc "remove multi_site's migrations first,then install again, useful for modifing some existing migration file!"
      task :reinstall_migrations => :environment do
          Dir[File.join(Rails.root,'db','migrate','*.rb')].sort.each{|file|
            if file=~/spree_multi_site.rb$/
              File.delete(file)
            end
          }
          Rake::Task['spree_multi_site:install:migrations'].invoke
      end
      #desc "Copies public assets of the Multi Site to the instance public/ directory."
      #task :bootstrap_multi_site => :environment do
        # Loading in all sample data into database.
        #site = Spree::Site.create(:name => "local", :domain => "localhost", :layout => "localhost")
        #site.products = Spree::Product.find(:all)
        #site.taxonomies = Spree::Taxonomy.find(:all)
        #site.orders = Spree::Order.find(:all)
        #site.save
      #end
    end
  end
end
