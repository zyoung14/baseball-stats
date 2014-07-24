require 'csv'

years = *(1993...2013)

def off_compute_efficiency(arr)
	singles = arr[8].to_f - (arr[9].to_f + arr[10].to_f + arr[11].to_f)
	tb = singles + arr[9].to_f * 2 + arr[10].to_f * 3 + arr[11].to_f * 4 + arr[24].to_f + arr[15].to_f + arr[13].to_f - arr[14].to_f
	tb_per_run = tb/arr[7].to_f 
	return tb_per_run
end

def def_compute_efficiency(arr)
	singles = arr[7].to_f - (arr[8].to_f + arr[9].to_f + arr[10].to_f)
	tb = singles + arr[8].to_f * 2 + arr[9].to_f * 3 + arr[10].to_f * 4 + arr[22].to_f + arr[13].to_f + arr[11].to_f - arr[12].to_f  + arr[26].to_f
	tb_per_run = tb/arr[6].to_f 
	return tb_per_run
end

def net_efficiency(arr1, arr2)
	return (def_compute_efficiency(arr1) - off_compute_efficiency(arr2))
end

#calculate scatterplot points for team efficiency ratings in 2011/12 and 2012/13
CSV.open('scatter_plot.csv', 'w',
	:write_headers=> true,
	:headers => ["Team", "Year 1", "Year 2"]
	) do |writer|

	years.each do |year|
		year1 = (CSV.read("Stat_Bank/#{year}Off.csv")[1 .. -1]).zip(CSV.read("Stat_Bank/#{year}Def.csv")[1 .. -1])
		year2 = (CSV.read("Stat_Bank/#{year+1}Off.csv")[1 .. -1]).zip(CSV.read("Stat_Bank/#{year+1}Def.csv")[1 .. -1])
		
		year1.zip(year2).each do |first, second|
			writer << [first[0][0], net_efficiency(first[1], first[0]), net_efficiency(second[1], second[0])] 
			# Way to get year included? i.e. "11/12"
		end
	end
end

# #calculate team off and def efficiency ratings for first half of 2014
# CSV.open('2014_results.csv', 'w', 
# 	:write_headers=> true,
# 	:headers => ["Team", "Offensive Clutch", "Defensive Clutch", "Total Clutch"]
# 	) do |writer|

# 	year1 = (CSV.read("Stat_Bank/2005Off.csv")[1 .. -1]).zip(CSV.read("Stat_Bank/2005Def.csv")[1 .. -1])
# 	year1.each do |team_off, team_def|
# 	#data goes here
# 	end
# end	
