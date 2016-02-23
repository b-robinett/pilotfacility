class RunController < ApplicationController
  
  def dashboard
    @current = Run.where("Actual_start_date < ? and Actual_end_date > ?", Date.today, Date.today)
  end
  
  def approval
    @awaiting = Run.where("Actual_start_date IS NULL")
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
                      :Reactor_ID => params[:run][:Reactor_ID]
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
  
end
