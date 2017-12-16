#module AttributeValidatorCleaner
#  def remove_attribute_validator( attribute_name)
#    #refer to http://stackoverflow.com/questions/7545938/how-to-remove-validation-using-instance-eval-clause-in-rails
#    #remove original defined validator first.
#    _validators.reject!{ |key, _| key == attribute_name.to_sym }
#  
#    _validate_callbacks.reject! do |callback|
#      if callback.raw_filter.respond_to? :attributes
#        #callback.raw_filter maybe symbol, ex. :validate_associated_records_for_tax_rates:Symbol 
#        callback.raw_filter.attributes == [attribute_name.to_sym]
#      end
#    end
#  end
#end