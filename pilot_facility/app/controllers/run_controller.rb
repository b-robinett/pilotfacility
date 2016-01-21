class RunController < ApplicationController
  
  def dashboard
    @current = Run.where("created_at < ?", Date.today)
  end
  
  def add_run
    @run = Run.new
  end
  
  def confirm_run_add
    @run = Run.new
    
    @run.Reactor_Type = params[:run][:Reactor_Type]
    @run.Scientist = params[:run][:Scientist]
    @run.Media = params[:run][:Media]
    @run.pH = params[:run][:pH]
    @run.Light_Intensity = params[:run][:Light_Intensity]
    @run.Light_Path = params[:run][:Light_Path]
    @run.Temperature = params[:run][:Temperature]
    @run.Organism = params[:run][:Organism]
    @run.Strain_ID = params[:run][:Strain_ID]
    
    @run.save!
    
    @record = Run.last
    
  end

  def schedule
  end
  
  def update_run
    @input_id = params[:run_id_val]
    @target = Run.find(@input_id)
    Run.save_val(@target)
  end
  
  def confirm_run_update
    @var_to_change = params[:variable]
    @val_to_change = params[:value]
    @new_target = Run.find(@saved_val)
    #new_target.@var_to_change = @val_to_change
    #@target.save!
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
    end
    
    @Value = params[:value].to_s
    @results = Run.where(@Variable => @Value)
  end
  
end
