require File.expand_path("../spec_helper", __FILE__)

module Danger
  describe Danger::DangerYamllint do
    it "should be a plugin" do
      expect(Danger::DangerYamllint.new(nil)).to be_a Danger::Plugin
    end

    #
    # You should test your custom attributes and methods here
    #
    describe "with Dangerfile" do
      before do
        # TODO
      end
    end
  end
end
