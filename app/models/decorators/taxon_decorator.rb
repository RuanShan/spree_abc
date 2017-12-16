Spree::Taxon.class_eval do
    #diable filters for now
    def applicable_filters
      fs = []
      # fs << ProductFilters.taxons_below(self)
      ## unless it's a root taxon? left open for demo purposes

      #fs << ProductFilters.price_filter if ProductFilters.respond_to?(:price_filter)
      #fs << ProductFilters.brand_filter if ProductFilters.respond_to?(:brand_filter)
      fs
    end
end