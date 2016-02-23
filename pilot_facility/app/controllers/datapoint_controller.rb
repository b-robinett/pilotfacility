class DatapointController < ApplicationController
  
  def results
    @run_data = Datapoint.where(Run_ID: params[:run_id_val])
  end
  
  def update_data
    @dp_target = Datapoint.find(params[:dp_id_val])
  end
  
  def confirm_data_update
     @dp_new_target = Datapoint.find(params[:datapoint][:id])
     @dp_new_target.update(:Submitter => params[:datapoint][:Submitter],
                      :Run_ID => params[:datapoint][:Run_ID],
                      :Time_Taken => params[:datapoint][:Time_Taken],
                      :Hrs_Post_Start => params[:datapoint][:Hrs_Post_Start],
                      :Var_Name => params[:datapoint][:Var_Name],
                      :Var_Metric => params[:datapoint][:Var_Metric],
                      :Var_Value => params[:datapoint][:Var_Value],
                      :Notes => params[:datapoint][:Notes]
                      )
  end
  
  def add_data
    @datapoint = Datapoint.new()
  end
  
  def confirm_data_add
    @datapoint = Datapoint.new()
    
    @datapoint.Run_ID = params[:datapoint][:Run_ID]
    @datapoint.Submitter = params[:datapoint][:Submitter]
    @datapoint.Time_Taken = params[:datapoint][:Time_Taken]
    @datapoint.Hrs_Post_Start = params[:datapoint][:Hrs_Post_Start]
    @datapoint.Var_Name = params[:datapoint][:Var_Name]
    @datapoint.Var_Metric = params[:datapoint][:Var_Metric]
    @datapoint.Var_Value = params[:datapoint][:Var_Value]
    @datapoint.Notes = params[:datapoint][:Notes]
    
    @datapoint.save!
    
    @dp_record = Datapoint.last
  end
  
end
