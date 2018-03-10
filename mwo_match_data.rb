require 'pp'

require 'open-uri'
require 'openssl'
require 'json'
require 'pry'

OpenSSL::SSL::VERIFY_PEER = OpenSSL::SSL::VERIFY_NONE

match_id = File.read("matches.txt").lines.first.strip

match_data = open("https://mwomercs.com/api/v1/matches/#{match_id}?api_token=s3JxhPn7OMYZQNvY8mBnQZteaeMbm5jlnLD2gow6ywBWqfIFet1jiZmentvv")
contents = JSON.load(match_data.read)


# pp contents

File.write("output.txt", contents)

puts contents['MatchDetails']['Map']
puts

array = contents['UserDetails']
# Filter non-participants
array = array.reject { |x| x["Team"].nil? }
array = array.reject { |x| x["Damage"] == 0 }
array = array.reject { |x| x["Team"] == "2" }

# order
array = array.sort_by {|x| x["HealthPercentage"]}


# array = array.collect { |x| [ x["Team"], x["Username"], x["TeamDamage"], x["HealthPercentage"] ] }

# View
array = array.map { |x| [ "#{x['Username']}\n  [#{x['MechName']}]\n  dmg: #{x['Damage']}\n  Remaining HP: #{x['HealthPercentage']}%" ] }

File.open("remainder.txt", "w") do |f|
  f.puts array
end
