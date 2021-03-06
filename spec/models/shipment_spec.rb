require 'rails_helper'

describe Shipment do
  describe "RDF type" do
    subject { described_class.new.type }
    it { is_expected.to contain_exactly(AICType.Shipment, AICType.Resource, AICType.CitiResource) }
  end

  describe "terms" do
    subject { described_class.new }
    ShipmentPresenter.terms.each do |term|
      it { is_expected.to respond_to(term) }
    end
  end

  it_behaves_like "a model for a Citi resource"
  it_behaves_like "an unfeatureable model"
end
