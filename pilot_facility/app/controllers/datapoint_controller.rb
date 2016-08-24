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

    start_day = target_run["Actual_start_date"].to_date
    end_day = target_run["Actual_end_date"].to_date
    if end_day.nil?
      end_day = Date.today
    end

    @dp_id_list = Array.new()
    @dp_err_arr = Array.new()

    if (params[:Time_Taken].to_date >= start_day) && (params[:Time_Taken].to_date <= end_day)
      
      hrs_post_start = (params[:Time_Taken].to_date - start_day) * 24

      var_Name_Arr = ["Optical Density","Dry Weight","pH Probe","pH Meter","BG11 Plate","LB Plate"]
      var_Metric_Arr = ["A750","Milligram","pH","pH","CFU", "CFU"]
      var_Value_Arr = [params[:OD], dw_calc, params[:pH_Probe], params[:pH_Meter], params[:BG], params[:LB]] 

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
    else
      @dp_err_arr[0] = "Date Taken does not fall within Run Schedule"
    end
  end
  
  def add_tot_protein
  end

  def confirm_tot_protein
    @Submitter = params[:Submitter]
    @filecontent = params[:tp_data_file].read
    @data_arr = @filecontent.split(' ')
    @data_arr = @data_arr[33..128]

    @plate_data = Array.new()
    temp_arr = Array.new()

    @plate_file = params[:plate_layout_file]
    CSV.foreach(@plate_file.path) do |row|
      if !row.nil?
        temp_arr.push(row)
      end
    end

    temp_arr.delete_at(0)

    for i in temp_arr
      i.delete_at(0)
      for x in i
        @plate_data.push(x)
      end
    end

    @tot_prot_hash = Hash[@plate_data.zip @data_arr]
    @tot_prot_hash.delete_if { |k,v| k.nil? }

    std_mgml = []
    std_abs = []

    @tot_prot_hash.each do |k,v|
      if k.include? "std"
        temp = k[4..-1].to_f
        std_abs.push(v.to_f)
        std_mgml.push(temp) 
        @tot_prot_hash.delete(k)
      else
        @tot_prot_hash[k] = v.to_f
      end
    end

    @std_hash = Hash[std_mgml.zip std_abs]

    vec_std_mgml = std_mgml.to_vector()
    vec_std_abs = std_abs.to_vector()

    @std_curve = Statsample::Regression::simple(vec_std_mgml,vec_std_abs)
    slope = @std_curve.b
    intercept = @std_curve.a 

    @prot_hash_todb = {}

    @tot_prot_hash.each do |r,w|
      
      name_arr = r.split("_")
      run_id = name_arr[0][1..-1].to_i
      date = name_arr[1]
      month = date[0..1].to_i
      day = date[2..3].to_i
      year = date[4..7].to_i
      
      if date.length > 8
        puts "True"
        hour = date[8..9].to_i
        minute = date[10..11].to_i
        new_date = DateTime.new(year,month,day,hour,minute)
        puts new_date
      else
        new_date = DateTime.new(year,month,day)
      end
      

      prot_val = ((w - intercept) / slope).round(4)

      @prot_hash_todb[run_id] = [prot_val, new_date]
    end
  end

  def tot_prot_todb
    @prot_hash = params[:data_hash]
    submitter = params[:submitter]
    @dp_id_list = []

    @prot_hash.each do |x,y|
      begin
        target_run = Run.find(x)
      rescue ActiveRecord::RecordNotFound
        flash[:notice] = "ERROR: No Run with id " + x.to_s
        redirect_to :action => 'add_tot_protein'
      end

      start_day = target_run["Actual_start_date"].to_date
      end_day = target_run["Actual_end_date"].to_date
      
      if end_day.nil?
        end_day = Date.today
      end

      if (y[1].to_datetime >= start_day) && (y[1].to_datetime <= end_day)
        curr_data = Datapoint.where("RUN_ID = ? and Var_Name = ? and Var_Value IS NOT NULL",x, "Total Protein").last

        hours = y[1].to_datetime.strftime("%H").to_i
        puts hours
        testdate = y[1].to_date - start_day
        puts testdate
        hrs_post_start = ((y[1].to_date - start_day).to_i) * 24 + hours


        puts hrs_post_start

        if curr_data
          if curr_data.Time_Taken != y[1].to_datetime
            new_data = Datapoint.new()
            new_data.Run_ID = x
            new_data.Var_Name = "Total Protein"
            new_data.Var_Metric = "mg/mL"
            new_data.Var_Value = y[0].to_f
            new_data.Submitter = submitter
            new_data.Time_Taken = y[1].to_datetime
            new_data.Hrs_Post_Start = hrs_post_start
            new_data.save

            dp_id = Datapoint.last.id
            @dp_id_list.push(dp_id)
          end
        else
          new_data = Datapoint.new()
          new_data.Run_ID = x
          new_data.Var_Name = "Total Protein"
          new_data.Var_Metric = "mg/mL"
          new_data.Var_Value = y[0].to_f
          new_data.Submitter = submitter
          new_data.Time_Taken = y[1].to_datetime
          new_data.Hrs_Post_Start = hrs_post_start
          new_data.save

          dp_id = Datapoint.last.id
          @dp_id_list.push(dp_id)
        end

      end

    end

    begin
      @dp_added = Datapoint.where(id: @dp_id_list)
    rescue ActiveRecord::RecordInvalid => @invalid
    end

  end

end
