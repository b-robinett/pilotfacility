class RunController < ApplicationController
  
  def dashboard
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
     
  end

  def schedule
  end
  
  def update_run
  end
  
  def confirm_run_update
  end
  
  def search
  end
  
  def search_results
  end
  
end
