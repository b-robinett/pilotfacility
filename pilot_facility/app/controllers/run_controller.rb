class RunController < ApplicationController
  
  def dashboard
    @current = Run.where("Actual_end_date >= ? or Actual_end_date IS NULL", Date.today).where("Actual_start_date <= ?", Date.today)
    @master_dict = Hash.new
    @current.each do |p|
      create_dict(p,@master_dict)
    end
  end

  def create_dict(record,target_dict)
    mini_dict = Hash.new
    last_OD_rec = Datapoint.where("Run_ID = ? and Var_Name = ?", record[:id], "Optical Density").last()

    puts "here"
    puts last_OD_rec

    
    if last_OD_rec
      mini_dict["Last_OD_date"] = last_OD_rec[:Time_Taken].to_date
      mini_dict["Last_OD_val"] = last_OD_rec[:Var_Value]
    else
      mini_dict["Last_OD_date"] = "NA"
      mini_dict["Last_OD_val"] = "NA"
    end

    mini_dict["Start_date"] = record[:Actual_start_date].to_date
    mini_dict["Organism"] = record[:Organism]
    mini_dict["Strain_ID"] = record[:Strain_ID]
    mini_dict["Reactor_Type"] = record[:Reactor_Type]
    mini_dict["Reactor_ID"] = record[:Reactor_ID]
    mini_dict["Light_Intensity"] = record[:Light_Intensity]
    mini_dict["Light_Notes"] = record[:Lightnotes]

    target_dict[record[:id]] = mini_dict
  end
  
  def approval
    @awaiting = Run.where("Actual_end_date IS NULL")
  end
  
  def add_run
    @run = Run.new
  end
  
  def confirm_run_add
    @run = Run.new
    
    @run.Scientist = params[:run][:Scientist].downcase
    @run.Actual_start_date = params[:run][:Actual_start_date]
    @run.Reactor_ID = params[:run][:Reactor_ID]
    @run.Reactor_Type = params[:run][:Reactor_Type]
    @run.Organism = params[:run][:Organism]
    @run.Strain_ID = params[:run][:Strain_ID]
    @run.Parent_Run = params[:run][:Parent_Run]
    @run.Actual_end_date = params[:run][:Actual_end_date]

    if params[:Condition] == 'Specific'
      @run.Media = params[:run][:Media]
      @run.pH = params[:run][:pH]
      @run.Start_OD = params[:run][:Start_OD]
      @run.Light_Intensity = params[:run][:Light_Intensity]
      @run.Lightnotes = params[:run][:Lightnotes].downcase
      @run.Light_Path = params[:run][:Light_Path]
      @run.Temperature = params[:run][:Temperature]
      @run.Air_Flow = params[:run][:Air_Flow]
      @run.CO2_Flow = params[:run][:CO2_Flow]
      @run.Day_Harvested = params[:run][:Day_Harvested]
      @run.Reactor_Pos = params[:run][:Reactor_Pos]
      @run.Media_ID = params[:run][:Media_ID]
      @run.Reactor_vol = params[:run][:Reactor_vol]
    elsif params[:Condition] == 'Standard Seed Train'
      @run.Media = '1X SOT'
      @run.pH = 9.5
      @run.Start_OD = 0.1
      @run.Light_Intensity = 200
      @run.Lightnotes = 'white'
      @run.Light_Path = 13.5
      @run.Temperature = 30
      @run.Air_Flow = 3
      @run.CO2_Flow = 0.3
      @run.Reactor_Pos = params[:run][:Reactor_Pos]
      @run.Media_ID = params[:run][:Media_ID]
      @run.Reactor_vol = 10
    elsif params[:Condition] == 'Standard Flask'
      @run.Media = '1X SOT'
      @run.pH = 9.8
      @run.Start_OD = 0.25
      @run.Light_Intensity = 120
      @run.Lightnotes = 'white'
      @run.Light_Path = 2
      @run.Temperature = 30
      @run.Media_ID = params[:run][:Media_ID]
      @run.Reactor_vol = 0.1
    end

    @run.save!
    
    @record = Run.last
    
  end

  def schedule
  end
  
  def update_run
    @target = Run.find(params[:run_id_val])
  end
  
  def confirm_run_update
    @new_target = Run.find(params[:run][:id])
    @new_target.update(:Scientist => params[:run][:Scientist],
                      :Reactor_Type => params[:run][:Reactor_Type],
                      :Media => params[:run][:Media],
                      :pH => params[:run][:pH],
                      :Start_OD => params[:run][:Start_OD],
                      :Light_Intensity => params[:run][:Light_Intensity],
                      :Lightnotes => params[:run][:Lightnotes],
                      :Light_Path => params[:run][:Light_Path],
                      :Temperature => params[:run][:Temperature],
                      :Organism => params[:run][:Organism],
                      :Strain_ID => params[:run][:Strain_ID],
                      :Actual_start_date => params[:run][:Actual_start_date],
                      :Actual_end_date => params[:run][:Actual_end_date],
                      :Reactor_ID => params[:run][:Reactor_ID],
                      :Reactor_Pos => params[:run][:Reactor_Pos],
                      :Day_Harvested => params[:run][:Day_Harvested],
                      :Media_ID => params[:run][:Media_ID],
                      :Parent_Run => params[:run][:Parent_Run],
                      :Reactor_vol => params[:run][:Reactor_vol],
                      :Air_Flow => params[:run][:Air_Flow],
                      :CO2_Flow => params[:run][:CO2_Flow]
                      )
  end
  
  def search
  end
  
  def search_results
    @Input_Var = params[:variable].to_s
    
    case @Input_Var
    when "Run ID"
      @Variable = "id"
    when "Reactor Type"
      @Variable = "Reactor_Type"
    when "Strain ID"
      @Variable = "Strain_ID"
    when "Light Intensity"
      @Variable = "Light_Intensity"
    when "Media ID"
      @Variable = "Media_ID"
    end
    
    @Value = params[:value].to_s
    @results = Run.where(@Variable => @Value).where("Actual_end_date IS NOT NULL")

    @result_runs = []

    @results.each do |rec|
      @result_runs.push(rec[:id].to_int)
    end   
  end

  def download_data
    @dp_data = Datapoint.where(Run_ID: params[:result_runs])
    respond_to do |format|
      format.html
      format.csv { send_data @dp_data.to_csv}
    end
  end
  
  def report
    @id_passed = params[:run_id]

    @od_data = Datapoint.where("Run_ID = ? and Var_Name = ?", params[:run_id], "Optical Density")
    @pH_data = Datapoint.where("Run_ID = ? and Var_Name = ?", params[:run_id], "pH Probe")
    @dw_data = Datapoint.where("Run_ID = ? and Var_Name = ?", params[:run_id], "Dry Weight") 
    @cpc_data = Datapoint.where("Run_ID = ? and Var_Name = ?", params[:run_id], "CPC") 

    dw_hash = obj_hash_convert(@dw_data)
    cpc_hash = obj_hash_convert(@cpc_data)
    od_hash = obj_hash_convert(@od_data)
    @cpc_per_dw = pc_analysis(dw_hash, cpc_hash)

    @combo_hash = {}

    dw_hash.each do |k,v|
      if od_hash.has_key? (k)
        @combo_hash[v] = od_hash[k]
      end
    end

    dw_list = []
    od_list = []

    @combo_hash.each do |dw_val,od_val|
      dw_list.push(dw_val)
      od_list.push(od_val)
    end

    vec_dw_list = dw_list.to_vector()
    vec_od_list = od_list.to_vector()

    unless dw_list.length < 3
      @stat = true
      @r_squared = Statsample::Regression::simple(vec_dw_list,vec_od_list)
    else
      @stat = false
    end

    @norm_od_data = normalize_data(od_hash)
  end

  def comparison_setup
  end

  def comparison_report
    @input_val = params[:value].to_s.gsub(/\s+/, "")
    @run_array = @input_val.split(",")

    compile_data(@run_array)
  end

  def run_lineage
    @input_val = params[:run_lin_val]
    @run_array = []
    @run_array.push(@input_val)
    
    parent_run_id = 0
    run_to_search = @input_val

    for i in 1..100
      rec_holder = Run.find(run_to_search)
      if rec_holder.Parent_Run != nil
        parent_run_id = rec_holder.Parent_Run
        par_holder = Run.find(parent_run_id)
        if par_holder.Reactor_ID != nil
          run_to_search = parent_run_id
          @run_array.push(parent_run_id)
        else
          break
        end
      else
        break
      end
    end

    compile_data(@run_array)

    render "comparison_report"
  end

  def build_hash(runarray,target,var_name)
    runarray.each do |f|
      internal_hash = {}
      
      temp_data = Datapoint.where("Run_ID = ? and Var_Name = ?", f, var_name)

      temp_data.each do |rec| 
        internal_hash[rec.Hrs_Post_Start] = rec.Var_Value
      end
      
      target[f] = internal_hash
    end
  end

  def compile_data(runarray)
    @od_data = {}
    @dw_data = {}
    @pH_data = {}
    @cpc_data = {}

    build_hash(runarray, @od_data, "Optical Density")
    build_hash(runarray, @dw_data, "Dry Weight")
    build_hash(runarray, @pH_data, "pH Probe")
    build_hash(runarray, @cpc_data, "CPC")

    @cpc_per_dw = {}

    @dw_data.each do |k,v|
      temp_hash = {}
      
      v.each do |q,r|
        if @cpc_data[k].key?(q)
          temp_hash[q] = (@cpc_data[k][q]/100 * r)
        end
      end

      @cpc_per_dw[k] = temp_hash
    end

    @norm_od_data = Hash.new()

    run_id_array = []
    @od_data.each do |q,r|
      run_id_array.push(q.to_i)
      @norm_od_data[q] = normalize_data(r)
    end

    lowest_val = run_id_array.min
    puts lowest_val
    @norm_od_data.delete(lowest_val)
    check = @norm_od_data.has_key?(lowest_val)
    puts check
  end

  def obj_hash_convert(incoming_obj)
    temp_hash = {}
    
    incoming_obj.each do |u|
      temp_hash[u.Hrs_Post_Start] = u.Var_Value
    end

    return temp_hash
  end

  def normalize_data(raw_data)

    start_val = 0
    normalized_hash = {}

    raw_data.each do |q,r|
      if q == 0
        start_val = r
      end
      normalized_hash[q] = ((r/start_val).to_f * 100).to_i
    end
    
    return normalized_hash
  end

  def pc_analysis(dw_data, pc_data)
    pc_per_dw = {}

    dw_data.each do |k,v|
      if pc_data.key?(k)
        pc_per_dw[k] = ((pc_data[k]/100) * v)
      end
    end

    return pc_per_dw
  end

end