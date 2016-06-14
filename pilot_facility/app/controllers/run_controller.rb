class RunController < ApplicationController
  
  def dashboard
    @current = Run.where("Actual_start_date <= ? and Actual_end_date IS NULL", Date.today)
    @master_dict = Hash.new
    @current.each do |p|
      create_dict(p,@master_dict)
    end
  end

  def create_dict(record,target_dict)
      mini_dict = Hash.new
      last_OD_rec = Datapoint.where("id = ? and Var_Value = ?",record[:id], "Optical Density").last()
      
      if last_OD_rec
        mini_dict["Last_OD_date"] = last_OD_rec[:Time_Taken]
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

      target_dict[record[:id]] = mini_dict
  end

  def
  
  def approval
    @awaiting = Run.where("Actual_end_date IS NULL")
  end
  
  def add_run
    @run = Run.new
  end
  
  def confirm_run_add
    @run = Run.new
    
    @run.Reactor_Type = params[:run][:Reactor_Type]
    @run.Scientist = params[:run][:Scientist]
    @run.Organism = params[:run][:Organism]
    @run.Strain_ID = params[:run][:Strain_ID]
    @run.Media = params[:run][:Media]
    @run.pH = params[:run][:pH]
    @run.Start_OD = params[:run][:Start_OD]
    @run.Light_Intensity = params[:run][:Light_Intensity]
    @run.Light_Path = params[:run][:Light_Path]
    @run.Temperature = params[:run][:Temperature]
    @run.Air_Flow = params[:run][:Air_Flow]
    @run.CO2_Flow = params[:run][:CO2_Flow]
    @run.Day_Harvested = params[:run][:Day_Harvested]
    @run.Actual_start_date = params[:run][:Actual_start_date]
    @run.Reactor_Type = params[:run][:Reactor_Type]
    @run.Reactor_ID = params[:run][:Reactor_ID]
    @run.Reactor_Pos = params[:run][:Reactor_Pos]
    @run.Media_ID = params[:run][:Media_ID]
    @run.Parent_Run = params[:run][:Parent_Run]
    @run.Actual_end_date = params[:run][:Actual_end_date]

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
    
    if @Input_Var == "Run ID"
      @Variable = "id"
    elsif @Input_Var == "Reactor Type"
      @Variable = "Reactor_Type"
    elsif @Input_Var == "Reactor ID"
      @Variable = "Reactor_ID"
    elsif @Input_Var == "Strain ID"
      @Variable = "Strain_ID"
    elsif @Input_Var == "Scientist"
      @Variable = "Scientist"
    elsif @Input_Var == "Organism"
      @Variable = "Organism"
    end
    
    @Value = params[:value].to_s
    @results = Run.where(@Variable => @Value)
  end
  
  def report
    @id_passed = params[:run_id]

    @od_data = Datapoint.where("Run_ID = ? and Var_Name = ?", params[:run_id], "Optical Density")
    @pH_data = Datapoint.where("Run_ID = ? and Var_Name = ?", params[:run_id], "pH Probe")
    @dw_data = Datapoint.where("Run_ID = ? and Var_Name = ?", params[:run_id], "Dry Weight") 

    dw_hash = Hash.new
    od_hash = Hash.new
    
    @od_data.each do |f|
      od_hash[f.Hrs_Post_Start] = f.Var_Value
    end

    @dw_data.each do |u|
      dw_hash[u.Hrs_Post_Start] = u.Var_Value
    end

    @combo_hash = Hash.new

    dw_hash.each do |k,v|
      if od_hash.has_key? (k)
        @combo_hash[v] = od_hash[k]
      end
    end

    dw_list = Array.new()
    od_list = Array.new()

    @combo_hash.each do |dw_val,od_val|
      dw_list.push(dw_val)
      puts dw_val
      od_list.push(od_val)
      puts od_val
    end

    vec_dw_list = dw_list.to_vector()
    vec_od_list = od_list.to_vector()


    @r_squared = Statsample::Regression::simple(vec_dw_list,vec_od_list)
  end

  def comparison_setup
  end

  def comparison_report
    @input_val = params[:value].to_s.gsub(/\s+/, "")
    @run_array = @input_val.split(",")

    @od_data = {}
    @dw_data = {}
    @pH_data = {}

    build_hash(@od_data, "Optical Density")
    build_hash(@dw_data, "Dry Weight")
    build_hash(@pH_data, "pH Probe")
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

    @od_data = {}
    @dw_data = {}
    @pH_data = {}

    build_hash(@od_data, "Optical Density")
    build_hash(@dw_data, "Dry Weight")
    build_hash(@pH_data, "pH Probe")

    puts @run_array

    render "comparison_report"
  end

  def build_hash(target,var_name)
    @run_array.each do |f|
      internal_hash = {}
      
      temp_data = Datapoint.where("Run_ID = ? and Var_Name = ?", f, var_name)

      temp_data.each do |rec| 
        internal_hash[rec.Hrs_Post_Start] = rec.Var_Value
      end
      
      target[f] = internal_hash
    end
  end

end