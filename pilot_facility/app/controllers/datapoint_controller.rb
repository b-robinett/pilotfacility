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
    time_taken = datetime_convert(params[:datapoint][:Time_Taken],params[:datapoint][:Hour_Taken])
    
    results_array = hrs_post_start_convert(params[:datapoint][:Run_ID],time_taken,"add_data")
    valid_date = results_array[1]
    hrs_post_start = results_array[0]

    if valid_date
      begin
        curr_data = Datapoint.where("RUN_ID = ? and Var_Name = ? and Time_Taken = ?",params[:datapoint][:Run_ID], params[:datapoint][:Var_Name], time_taken).last
      rescue ActiveRecord::RecordNotFound
      end
            
      if curr_data.nil?
        @datapoint.Run_ID = params[:datapoint][:Run_ID]
        @datapoint.Submitter = params[:datapoint][:Submitter].downcase
        @datapoint.Time_Taken = time_taken
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

  def confirm_sample_set
    
    if params[:Dry_Weight_Post] != ""
      dw_calc = ((params[:Dry_Weight_Post].to_f - params[:Dry_Weight_Pre].to_f)/(params[:DW_vol].to_f)).round(3)
    else
      dw_calc = ""
    end

    time_taken = datetime_convert(params[:Time_Taken],params[:Hour_Taken])
    results_array = hrs_post_start_convert(params[:Run_ID],time_taken,"add_sample_set")
    valid_date = results_array[1]
    hrs_post_start = results_array[0]

    @dp_id_list = Array.new()
    @dp_err_arr = Array.new()

    if valid_date

      var_Name_Arr = ["Optical Density","Dry Weight","pH Probe","pH Meter","BG11 Plate","LB Plate"]
      var_Metric_Arr = ["A750","Milligram","pH","pH","CFU", "CFU"]
      var_Value_Arr = [params[:OD], dw_calc, params[:pH_Probe], params[:pH_Meter], params[:BG], params[:LB]] 

      for i in 0..5 
        if var_Value_Arr[i] != ""
          begin
            curr_data = Datapoint.where("RUN_ID = ? and Var_Name = ? and Time_Taken =?",params[:Run_ID], var_Name_Arr[i], time_taken).last
          rescue ActiveRecord::RecordNotFound
          end
          
          if curr_data.nil?
            sample_set = Datapoint.new()

            sample_set.Run_ID = params[:Run_ID]
            sample_set.Submitter = params[:Submitter]
            sample_set.Time_Taken = time_taken
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
        end
      end

      begin
        @dp_added = Datapoint.where(id: @dp_id_list)
      rescue ActiveRecord::RecordInvalid => @invalid
      end
    else
      @dp_err_arr[0] = "Date Taken does not fall within Run Schedule"
    end
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

    $prot_hash_todb = {}

    index = 1
    @tot_prot_hash.each do |r,w|
      
      name_arr = r.split("_")
      run_id = name_arr[0][1..-1].to_i
      date = name_arr[1]
      new_date = str_to_date(date)
      
      prot_val = ((w - intercept) / slope).round(4)

      $prot_hash_todb[index] = [run_id, prot_val, new_date]

      index += 1
    end
  end

  def tot_prot_todb
    submitter = params[:submitter]
    dp_id_list = []
    @bad_data = {}

    $prot_hash_todb.each do |x,y|
      
      exc_path = "add_tot_protein"
      valid_date = false
      results_array = hrs_post_start_convert(y[0],y[2],exc_path)
      valid_date = results_array[1]
      hrs_post_start = results_array[0]

      if valid_date
        begin
          @curr_data = Datapoint.where("RUN_ID = ? and Var_Name = ? and Time_Taken = ?",y[0], "Total Protein", y[2].to_datetime).last
        rescue ActiveRecord::RecordNotFound
        end

        if @curr_data.nil?
          new_data = Datapoint.new()
          new_data.Run_ID = y[0]
          new_data.Var_Name = "Total Protein"
          new_data.Var_Metric = "mg/mL"
          new_data.Var_Value = y[1].to_f
          new_data.Submitter = submitter
          new_data.Time_Taken = y[2].to_datetime
          new_data.Hrs_Post_Start = hrs_post_start
          new_data.save

          dp_id = Datapoint.last.id
          dp_id_list.push(dp_id)
        else
          @bad_data[x] = y
        end
      end
    end

    begin
      @dp_added = Datapoint.where(id: @dp_id_list)
    rescue ActiveRecord::RecordInvalid => @invalid
    end

    if @bad_data.empty? == false
      @bad_data_error_msg = "ERROR: Data already present for timepoints given. See Below."
    end
  end

  def confirm_pc
    @Submitter = params[:Submitter]
    pcfiledata = params[:pc_data_file].read
    pc_rows = pcfiledata.split("\n")
    pc_edited = [pc_rows[2],pc_rows[3],pc_rows[5],pc_rows[8],pc_rows[10]]

    clean_arr = []

    pc_edited.each do |i|
      temp = i.split(/\t/)
      clean_arr.push(temp)
    end
    clean_arr = clean_arr.transpose
    clean_arr = clean_arr.slice(2..-2)

    pc_data_hash = {}
    arr_to_hash(clean_arr, pc_data_hash)

    layout_file = params[:layout_file]
    
    csv = CSV.read(layout_file.path) 
    final_arr = csv.transpose
    final_arr.delete_at(0)
    
    layout_hash = {}
    arr_to_hash(final_arr, layout_hash)

    @error_hash = {}
    $pc_data_todb = []
    pdt_index = 0

    pc_data_hash.each do |k,v|
      if layout_hash.has_key?(k) && layout_hash[k][1]
        dil_val = layout_hash[k][2].to_i
        run_id = layout_hash[k][0].to_i
        raw_time_taken = layout_hash[k][1]
        time_taken = str_to_date(raw_time_taken)

        cpc_mgml = ((0.162 * (v[1].to_f-v[3].to_f)) - (0.098 * (v[0].to_f-v[2].to_f))) * dil_val
        apc_mgml = ((0.18 * (v[0].to_f-v[2].to_f)) - (0.042 * (v[1].to_f-v[3].to_f))) * dil_val
        
        begin
          afdw = Datapoint.where("RUN_ID = ? and Var_Name = ? and Time_Taken = ?",run_id, "Dry Weight", time_taken).last
        rescue ActiveRecord::RecordNotFound
          @error_hash[k] = "Dry Weight Not Found"
        end

        begin
          optical_density = Datapoint.where("RUN_ID = ? and Var_Name = ? and Time_Taken = ?",run_id, "Optical Density", time_taken).last
        rescue ActiveRecord::RecordNotFound
          if error_hash.has_key?(k)
            @error_hash[k] = "Dry Weight and Optical Density Not Found"
          else
            @error_hash[k] = "Optical Density Not Found"
          end
        end

        if afdw && optical_density
          afdw_data = afdw.Var_Value
          optical_density_data = optical_density.Var_Value

          odml_vol = 0

          if layout_hash[k][4]
            odml_vol = layout_hash[k][4].to_i
          else
            odml_vol = 2 / optical_density_data
          end

          dw_in_sample = odml_vol * afdw_data
          mg_cpc_in_sample = (layout_hash[k][3].to_i * cpc_mgml / 1000)
          mg_apc_in_sample = (layout_hash[k][3].to_i * apc_mgml / 1000)
          percent_cpc = (mg_cpc_in_sample / dw_in_sample * 100).round(4)
          percent_apc = (mg_apc_in_sample / dw_in_sample * 100).round(4)

          $pc_data_todb[pdt_index] = [run_id, time_taken, "CPC", percent_cpc]
          $pc_data_todb[pdt_index + 1] = [run_id, time_taken, "APC", percent_apc]

          pdt_index += 2
        end
      end
    end
  end

  def pc_todb
    submitter = params[:submitter]
    dp_id_list = []
    @bad_data = {}
    index = 0

    $pc_data_todb.each do |y|
      exc_path = "add_pc_data"
      valid_date = false
      results_array = hrs_post_start_convert(y[0],y[1],exc_path)
      valid_date = results_array[1]
      hrs_post_start = results_array[0]

      if valid_date
        begin
          @curr_data = Datapoint.where("RUN_ID = ? and Var_Name = ? and Time_Taken = ?",y[0], y[2], y[1].to_datetime).last
        rescue ActiveRecord::RecordNotFound
        end

        if @curr_data.nil?
          new_data = Datapoint.new()
          new_data.Run_ID = y[0]
          new_data.Var_Name = y[2]
          new_data.Var_Metric = "Percent"
          new_data.Var_Value = y[3].to_f
          new_data.Submitter = submitter
          new_data.Time_Taken = y[1].to_datetime
          new_data.Hrs_Post_Start = hrs_post_start
          new_data.save

          dp_id = Datapoint.last.id
          dp_id_list.push(dp_id)
        else
          @bad_data[index] = [y[0],y[1],y[2],y[3]]
        end
      end

      index += 1
    end

    begin
      @dp_added = Datapoint.where(id: dp_id_list)
    rescue ActiveRecord::RecordInvalid => @invalid
    end

    if @bad_data.empty? == false
      @bad_data_error_msg = "ERROR: Data already present for timepoints given. See Below."
    end

  end

  def arr_to_hash(inputarray, targetfile)
    inputarray.each do |i|
      targetfile[i[0]] = i[1..-1]
    end
  end

  def str_to_date(datestring)
    month = datestring[4..5].to_i
    day = datestring[6..7].to_i
    year = datestring[0..3].to_i
    
    if datestring.length > 8
      hour = datestring[8..9].to_i
      minute = datestring[10..11].to_i
      new_date = DateTime.new(year,month,day,hour,minute)
    else
      new_date = DateTime.new(year,month,day)
    end

    return new_date
  end

  def hrs_post_start_convert(run_id,date,exc_path)
    begin
      target_run = Run.find(run_id)
    rescue ActiveRecord::RecordNotFound
      flash[:notice] = "ERROR: No Run with id " + run_id.to_s
      redirect_to :action => exc_path
    end

    start_day = target_run["Actual_start_date"].to_date
    
    if target_run["Actual_end_date"]
      end_day = target_run["Actual_end_date"].to_date
    else
      end_day = Date.today
    end

    hours = date.to_datetime.strftime("%H").to_i
    hrs_post_start = (((date.to_date - start_day).to_i) * 24) + hours
    
    if (date.to_datetime >= start_day) && (date.to_datetime <= end_day)
      valid_date = true
    end

    results_array = [hrs_post_start, valid_date]

    return results_array
  end

  def datetime_convert(date,time)
    date_array = date.split("/")
    date_array.map!(&:to_i)
    
    if time.nil? or time == ""
      time = 0
    end
    
    date_array.push(time)

    new_date = DateTime.new(date_array[2],date_array[0],date_array[1],date_array[3])
    return new_date
  end

end
