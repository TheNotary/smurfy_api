require 'pp'

require 'open-uri'
require 'openssl'
require 'json'
require 'pry'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

match_id = File.read("matches.txt").lines.first.strip

match_data = open("https://mwomercs.com/api/v1/matches/#{match_id}?api_token=#{ENV['mwo_api_key']}")
contents = JSON.load(match_data.read)


File.write("output.txt", contents)

puts contents['MatchDetails']['Map']
puts


def filter_participants(contents, team_num)
  array = contents['UserDetails']
  # Filter non-participants
  array = array.reject { |x| x["Team"].nil? }
  array = array.reject { |x| x["Damage"] == 0 }
  array = array.reject { |x| x["Team"] != team_num }
end


def health_remainders(contents, team_num)
  array = filter_participants(contents, team_num)

  array = array.sort_by {|x| x["HealthPercentage"]} # Order array

  # View Logic
  array = array.map { |x| [ "#{x['Username']}\n  [#{x['MechName']}]\n  dmg: #{x['Damage']}\n  Remaining HP: #{x['HealthPercentage']}%" ] }

  file = StringIO.open do |f|
    f.puts "#{contents['MatchDetails']['Map']} Health Remainders"

    f.puts "Team #{team_num}"
    f.puts
    f.puts array
    f.puts "\n\n"
    f.string
  end
end


def calc_dmg_per_component(x)
  (x['ComponentsDestroyed'].to_f / x['Damage'].to_f * 100.0).round(2)
end


def get_team_death_count(contents, team_num)
  array = filter_participants(contents, team_num)

  array.reject { |x| x["HealthPercentage"] > 0 }.length
end


def print_team_detail(contents, team_num)
  "Team #{team_num}"
end

def get_other_team_num(team_num)
  other_team_num = team_num == '1' ? '2' : '1'
end


# I need a ratio here that show performance of damage per component???
def component_per_dmg(contents, team_num)
  array = filter_participants(contents, team_num)

  array = array.sort_by {|x| calc_dmg_per_component(x) }.reverse # Order array
  total_components = array.collect { |x| x['ComponentsDestroyed'] }.reduce(:+)
  player_count = array.length
  other_team_num = get_other_team_num(team_num)
  opponent_death_count = get_team_death_count(contents, other_team_num)
  component_waste = total_components - (opponent_death_count * 2)
  extrapolated_waste = (player_count/ opponent_death_count) * component_waste
  match_result = contents['MatchDetails']['WinningTeam'] == team_num ? "WINNER" : "Loser"


  # View Logic
  array = array.map { |x| [ "#{x['Username']}\n  [#{x['MechName']}]\n  Components: #{x['ComponentsDestroyed']}\n  Kills: #{x['Kills']}\n  Components per Damage: #{(x['ComponentsDestroyed'].to_f / x['Damage'].to_f * 100.0).round(2)}%\n " ] }

  file = StringIO.open do |f|
    f.puts "#{contents['MatchDetails']['Map']} Component Efficacy"

    f.puts "#{print_team_detail(contents, team_num)}"
    f.puts
    f.puts "#{match_result}"
    f.puts "Components Opened and Destroyed by Team:  #{total_components}"
    f.puts "Component Waste: #{component_waste}"
    f.puts "Extrapolated Waste: #{extrapolated_waste}"
    #f.puts "Opponents Destroyed: #{opponent_death_count}"
    f.puts "Damage Waste: <total_team_damage - total_leg_armor + total_leg_structure>"
    f.puts
    f.puts array
    f.puts "\n\n"
    f.string
  end
  file
end


remainder = ""
remainder += health_remainders(contents, '2')
remainder += health_remainders(contents, '1')
File.open("remainder.txt", "w") { |f| f.puts remainder }

component_per_dmg = ""
component_per_dmg += component_per_dmg(contents, '2')
component_per_dmg += component_per_dmg(contents, '1')
File.open("cpd.txt", "w") { |f| f.puts component_per_dmg }

