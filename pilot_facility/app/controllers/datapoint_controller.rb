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

  def add_sample_set
    @sample_set = Datapoint.new()
  end

  def confirm_sample_set
    
    @dp_id_list = array.new()

    for i in 1..5 
      sample_set = Datapoint.new()

      
      sample_set.Run_ID = params[:sample_set][:Run_ID]
      sample_set.Submitter = params[:sample_set][:Submitter]
      sample_set.Time_Taken = params[:sample_set][:Time_Taken]
      sample_set.Hrs_Post_Start = params[:sample_set][:Hrs_Post_Start]
      sample_set.Var_Name = "Optical Density"
      sample_set.Var_Metric = "A750"
      sample_set.Var_Value = params[:sample_set][:OD]

      sample_set.save!
      dp_id = Datapoint.last.id
      @dp_id_list.push(dp_id)

    end




  end
  
end
