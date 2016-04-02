# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
for i in 1..5
	Run.create(Actual_start_date: '01/01/2016', Actual_end_date: '01/15/2016')
	puts i
	puts "is done"
	for k in 1..5
		Datapoint.create(Run_ID: i, 
						Hrs_Post_Start: (k * 24), 
						Var_Name: 'Optical Density',
						Var_Value: k)
		Datapoint.create(Run_ID: i, 
						Hrs_Post_Start: (k * 24), 
						Var_Name: 'pH Probe',
						Var_Value: (9.5 + k))
		Datapoint.create(Run_ID: i, 
						Hrs_Post_Start: (k * 24), 
						Var_Name: 'Dry Weight',
						Var_Value: k)
	end
end
