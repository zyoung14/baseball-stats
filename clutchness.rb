require 'csv'

years = *(1993...2013)
# what about Sacrifice Bunts?
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
	:headers => ["Team", "Year 1", "Year 2", "D-clutch1", "D-clutch2", "O-clutch1", "O-clutch2"]
	) do |writer|

	years.each do |year|
		year1 = (CSV.read("Stat_Bank/#{year}Off.csv")[1 .. -1]).zip(CSV.read("Stat_Bank/#{year}Def.csv")[1 .. -1])
		year2 = (CSV.read("Stat_Bank/#{year+1}Off.csv")[1 .. -1]).zip(CSV.read("Stat_Bank/#{year+1}Def.csv")[1 .. -1])
		year_1 = (year.to_s)[-2, 2]
		year_2 = (year + 1).to_s[-2,2]
		year_both = year_1 + "/" +year_2

		year1.zip(year2).each do |first, second|
			writer << [first[0][0]+ " " + year_both, net_efficiency(first[1], first[0]), net_efficiency(second[1], second[0]), def_compute_efficiency(first[1]), def_compute_efficiency(second[1]), off_compute_efficiency(first[0]), off_compute_efficiency(second[0])] 
		end
	end
end

#calculate win projections for each team
CSV.open('2014_results.csv', 'w', 
	:write_headers=> true,
	:headers => ["Team", "Wins", "Losses"]
	) do |writer|
 		
	wins = CSV.read("Stat_Bank/2014wins.csv")[1 .. -1]
	teams_2013 = (CSV.read("Stat_Bank/2013Off1.csv")[1 .. -1]).zip(CSV.read("Stat_Bank/2013Def1.csv")[1 .. -1])
	teams_2014 = (CSV.read("Stat_Bank/2014Off.csv")[1 .. -1]).zip(CSV.read("Stat_Bank/2014Def.csv")[1 .. -1])
	r_squared = [0.25162, 0.262] 
	league_average_efficiency = [3.912,4.012]

	(teams_2014.zip(wins)).zip(teams_2013).each do |team2014, team2013|
		g = team2014[0][1][3].to_f
		rs = (162/g - 1) * off_compute_efficiency(team2014[0][0]) * team2014[0][0][7].to_f / (r_squared[0] * off_compute_efficiency(team2013[0]) + (1 - r_squared[0]) * league_average_efficiency[0])
		ra = (162/g - 1) * def_compute_efficiency(team2014[0][1]) * team2014[0][1][6].to_f / (r_squared[1] * def_compute_efficiency(team2013[1]) + (1 - r_squared[1]) * league_average_efficiency[1])
		exp = ((rs + ra)/(162 - g))**0.287
		win_total = team2014[1][4].to_f + (162 - g) * (1/(1 + (ra/rs) ** exp))
		writer << [team2014[0][0][0], win_total, (162 - win_total)]
	end
end

#now we sort the results to descend from highest wins
a_of_a = (CSV.read("2014_results.csv")[1 .. -1]).sort_by { |c| c[2] }
CSV.open('2014_results.csv', 'w', 
	:write_headers=> true,
	:headers => ["Team", "Wins", "Losses"]
	) do |writer|
 	
 	a_of_a.each do |a|
 		writer << a
 	end
end