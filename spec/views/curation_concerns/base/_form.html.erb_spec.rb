# frozen_string_literal: true
require 'rails_helper'

describe 'curation_concerns/base/_form.html.erb' do
  let(:ability) { double }
  let(:form) { CurationConcerns::GenericWorkForm.new(work, ability) }

  before do
    allow(controller).to receive(:current_user).and_return(stub_model(User))
    assign(:form, form)
  end

  context "with a new asset" do
    let(:work) { GenericWork.new }
    before do
      view.stub(:action_name).and_return('new')
      render
    end
    it "includes select options for asset type" do
      expect(rendered).to include("<option value=\"#{AICType.StillImage}\">Still Image</option>")
      expect(rendered).to include("<option value=\"#{AICType.Text}\">Text</option>")
    end
  end

  context "when editing an existing asset" do
    let(:work) { build(:asset) }
    before { render }
    it "does not allow changing the asset type" do
      expect(rendered).not_to include("generic_work[asset_type]")
    end
  end
end
