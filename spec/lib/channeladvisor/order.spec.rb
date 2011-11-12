require 'spec_helper'

module ChannelAdvisor
	describe Order do
	  describe ".list" do
	    context "without filters" do
	      it "returns an array of all orders" do
	      	orders = ChannelAdvisor::Order.list
	        orders.first.should
	      end
	    end
	    
	    context "with optional filters" do
	    	describe "created date from 11/1/11" do
	    	  it "should return only orders created after 11/1/11"
	    	end

	    	describe "created date before 11/1/11" do
	    	  it "should return only orders created before 11/1/11"
	    	end

	    	describe "created at between 11/1/11 and 11/5/11" do
	    	  it "should return only orders created between 11/1/11 and 11/5/11"
	    	end
	    end

	  end
	end
end