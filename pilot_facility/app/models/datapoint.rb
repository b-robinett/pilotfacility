class Datapoint < ActiveRecord::Base
	validates :Run_ID, :Submitter, :Hrs_Post_Start, :Var_Name, :Var_Metric, :Var_Value, presence: true
end
