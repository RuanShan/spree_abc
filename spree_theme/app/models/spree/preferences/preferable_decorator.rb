#Spree::Preferences::Preferable.class_eval do
#  #replace original :preference_cache_key, add current_site.id as part of key
#  #fix error Duplicate entry 'spree/calculator/flat_rate/amount/1'
#  def preference_cache_key(name)
#    return unless id
#    [self.class.name, name, id, Spree::Site.current.id].join('::').underscore
#  end
#end
