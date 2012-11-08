require File.dirname(__FILE__) + '/../../spec_helper'

describe "tables listing" do
  it "should respond to list" do
    DemocracyInAction::Tables.list.should be_an_instance_of(Array)
  end
end
