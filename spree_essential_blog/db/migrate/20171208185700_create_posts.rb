class CreatePosts < ActiveRecord::Migration
  def self.up
    create_table :spree_posts do |t|
      t.integer :site_id,      :default  => 0
      t.string     :title,     :required => true
      t.string     :permalink, :required => true
      t.string     :teaser
      t.datetime   :posted_at
      t.text       :body
      t.string     :author
      t.boolean    :live,      :default  => true
      t.timestamps
    end
  end

  def self.down
    drop_table :spree_posts
  end
end