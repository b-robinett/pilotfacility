class Run < ActiveRecord::Base
  validates :Scientist, :Actual_start_date, :Organism, :Strain_ID, :Reactor_Type, 
  :Light_Intensity, :Light_Path, :Media, :Media_ID, :Air_Flow, :CO2_Flow, :presence => true
  
  def Reactor_Type
  end
  
  def Scientist
  end
  
  def Media
  end
  
  def pH
  end
  
  def Light_Intensity
  end
  
  def Light_Path
  end
  
  def Temperature
  end
  
  def Organism
  end
  
  def Strain_ID
  end
  
  def self.save_val(value)
    @saved_val = value
  end
  
    
  
    
end
