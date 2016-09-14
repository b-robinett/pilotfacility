require 'test_helper'

class DatapointControllerTest < ActionController::TestCase
  
  test "add datapoint without run" do 
  	datapoint_test = Datapoint.new()
  	assert_not datapoint_test.save, "Saved datapoint without any information"
  end

  test "saved datapoint to run outside of possible dates" do
  	datapoint_test = Datapoint.new()
  	d = DateTime.new(2016,02,12)
  	datapoint_test.Time_Taken = d
  	assert_not datapoint_test.save, "Saved datapoint to run outside of possible dates"
  end



end
