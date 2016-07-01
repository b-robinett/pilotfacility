class Datapoint < ActiveRecord::Base
	validates :Run_ID, :Submitter, :Hrs_Post_Start, :Var_Name, :Var_Metric, :Var_Value, presence: true

	def self.to_csv(options = {})
		CSV.generate(options) do |csv|
			csv << column_names
			all.each do |result|
				csv << result.attributes.values_at(*column_names)
			end
		end
	end

end
