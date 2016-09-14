require 'test_helper'

class RunControllerTest < ActionController::TestCase
   
   test "add run without any information" do
     test_run = Run.new()
     assert_not test_run.save, "Saved run without any information"
  end

end
