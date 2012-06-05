require 'spec_helper'

module ChannelAdvisor
  describe Address do
      before(:each) do
        @attrs = {
          :address_line1 => "12345 Some Pl.",
          :address_line2 => "Ste. 1",
          :city => "Somewhere",
          :region => "NY",
          :region_description => "New York",
          :postal_code => "10003",
          :country_code => "US",
          :company_name => "Some Company",
          :job_title  => "President",
          :title => "Mr.",
          :first_name => "Some",
          :last_name => "Body",
          :suffix => "Sr.",
          :phone_number_day => "999-999-9999",
          :phone_number_evening => "555-555-5555"
        }
        @address = Address.new(@attrs)
      end

    describe ".new" do
      it "sets @line1" do
        @address.line1.should == @attrs[:address_line1]
      end

      it "sets @line2" do
        @address.line2.should == @attrs[:address_line2]
      end

      it "sets @city" do
        @address.city.should == @attrs[:city]
      end

      it "sets @region" do
        @address.region.should == @attrs[:region]
      end

      it "sets @region_description" do
        @address.region_description.should == @attrs[:region_description]
      end

      it "sets @postal_code" do
        @address.postal_code.should == @attrs[:postal_code]
      end

      it "sets @country_code" do
        @address.country_code.should == @attrs[:country_code]
      end

      it "sets @company_name" do
        @address.company_name.should == @attrs[:company_name]
      end

      it "sets @job_title" do
        @address.job_title.should == @attrs[:job_title]
      end

      it "sets @title" do
        @address.title.should == @attrs[:title]
      end

      it "sets @first_name" do
        @address.first_name.should == @attrs[:first_name]
      end

      it "sets @last_name" do
        @address.last_name.should == @attrs[:last_name]
      end

      it "sets @suffix" do
        @address.suffix.should == @attrs[:suffix]
      end

      it "sets @daytime_phone" do
        @address.daytime_phone.should == @attrs[:phone_number_day]
      end

      it "sets @evening_phone" do
        @address.evening_phone.should == @attrs[:phone_number_evening]
      end
    end

    describe "#full_name" do
      it "returns a full name string" do
        @address.full_name.should == "Mr. Some Body, Sr."
      end
    end

    describe "#formatted" do
      it "returns a formatted address" do
        @address.formatted.should == <<-EOF
        Mr. Some Body, Sr.
        President
        12345 Some Pl.
        Ste. 1
        Somewhere, NY 10003
        US
        EOF
      end
    end
  end
end