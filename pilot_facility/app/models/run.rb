class Run < ActiveRecord::Base
  
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
