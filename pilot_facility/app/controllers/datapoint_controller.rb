class DatapointController < ApplicationController
  
  def results
    @run_data = Datapoint.where(Run_ID: params[:run_id_val])
  end
  
  def update_data
    @dp_target = Datapoint.find(params[:dp_id_val])
  end
  
  def confirm_data_update
     @dp_new_target = Datapoint.find(params[:datapoint][:id])
     @dp_new_target.update(:Submitter => params[:datapoint][:Submitter].downcase,
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
    
    curr_data = Datapoint.where("RUN_ID = ? and Var_Name = ? and Var_Value IS NOT NULL",params[:datapoint][:Run_ID], params[:datapoint][:Var_Name]).last

    if curr_data
      if curr_data.Time_Taken != params[:datapoint][:Time_Taken]
        @datapoint.Run_ID = params[:datapoint][:Run_ID]
        @datapoint.Submitter = params[:datapoint][:Submitter].downcase
        @datapoint.Time_Taken = params[:datapoint][:Time_Taken]
        @datapoint.Hrs_Post_Start = params[:datapoint][:Hrs_Post_Start]
        @datapoint.Var_Name = params[:datapoint][:Var_Name]
        @datapoint.Var_Metric = params[:datapoint][:Var_Metric]
        @datapoint.Var_Value = params[:datapoint][:Var_Value]
        @datapoint.Notes = params[:datapoint][:Notes]
        
        @datapoint.save!
        @dp_record = Datapoint.last
      else
        @dp_record = curr_data
        @dp_err = true
      end
    end

  end

  def add_sample_set
    @sample_set = Datapoint.new()
  end

  def confirm_sample_set
    
    if params[:Dry_Weight_Post] != ""
      dw_calc = ((params[:Dry_Weight_Post].to_f - params[:Dry_Weight_Pre].to_f)/(params[:DW_vol].to_f)).round(3)
    else
      dw_calc = ""
    end
    
    begin
      target_run = Run.find(params[:Run_ID])
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "ERROR: No Run with id " + params[:Run_ID].to_s
      redirect_to :action => 'add_sample_set'
    end

    if target_run
      start_day = target_run["Actual_start_date"].to_date
      hrs_post_start = (params[:Time_Taken].to_date - start_day) * 24

      var_Name_Arr = ["Optical Density","Dry Weight","pH Probe","pH Meter","BG11 Plate","LB Plate"]
      var_Metric_Arr = ["A750","Milligram","pH","pH","CFU", "CFU"]
      var_Value_Arr = [params[:OD], dw_calc, params[:pH_Probe], params[:pH_Meter], params[:BG], params[:LB]] 

      @dp_id_list = Array.new()
      @dp_err_arr = Array.new()
      
      for i in 0..5 
        if var_Value_Arr[i] != ""
          
          curr_data = Datapoint.where("RUN_ID = ? and Var_Name = ? and Var_Value IS NOT NULL",params[:Run_ID], var_Name_Arr[i]).last

          if curr_data
            if curr_data.Time_Taken != params[:Time_Taken]
              sample_set = Datapoint.new()

              sample_set.Run_ID = params[:Run_ID]
              sample_set.Submitter = params[:Submitter]
              sample_set.Time_Taken = params[:Time_Taken]
              sample_set.Hrs_Post_Start = hrs_post_start
              sample_set.Var_Name = var_Name_Arr[i]
              sample_set.Var_Metric = var_Metric_Arr[i]
              sample_set.Var_Value = var_Value_Arr[i]

              sample_set.save
              
              dp_id = Datapoint.last.id
              @dp_id_list.push(dp_id)

            else
              @dp_err_arr.push(var_Name_Arr[i])
              puts @dp_err_arr
            end
          else
            sample_set = Datapoint.new()

            sample_set.Run_ID = params[:Run_ID]
            sample_set.Submitter = params[:Submitter]
            sample_set.Time_Taken = params[:Time_Taken]
            sample_set.Hrs_Post_Start = hrs_post_start
            sample_set.Var_Name = var_Name_Arr[i]
            sample_set.Var_Metric = var_Metric_Arr[i]
            sample_set.Var_Value = var_Value_Arr[i]

            sample_set.save
            
            dp_id = Datapoint.last.id
            @dp_id_list.push(dp_id)
          end
        end
      end
      
      #puts @dp_id_list

      begin
        @dp_added = Datapoint.where(id: @dp_id_list)
      rescue ActiveRecord::RecordInvalid => @invalid
      end
    end
  end
  
end
