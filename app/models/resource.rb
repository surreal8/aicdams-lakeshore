# frozen_string_literal: true
class Resource < ActiveFedora::Base
  def self.aic_type
    [AICType.Resource]
  end

  # Defines a x_uris= or x_uri= method where "x" is the property
  def self.accepts_uris_for(*fields)
    fields.each do |field|
      if multiple?(field)
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{field}_uris=(uris)
            raise(ArgumentError, "argument must be an array") unless uris.kind_of?(Array)
            uris.keep_if(&:present?)
            self.send("#{field}=", uris.map { |x| ::RDF::URI(x) })
          end
        CODE
      else
        class_eval <<-CODE, __FILE__, __LINE__ + 1
          def #{field}_uri=(uri)
            return unless uri.present?
            self.send("#{field}=", ::RDF::URI(uri))
          end
        CODE
      end
    end
  end

  include BasicMetadata
  include ResourceMetadata
  include WithStatus

  type aic_type

  private

    # Returns the correct type class for attributes when loading an object from Solr
    # Catches malformed dates that will not parse into DateTime, see #198
    def adapt_single_attribute_value(value, attribute_name)
      AttributeValueAdapter.call(value, attribute_name) || super
    rescue ArgumentError
      "#{value} is not a valid date"
    end
end
