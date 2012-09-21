require 'csv'
require 'json'

input_path = ARGV[0]
output_name = ARGV[1]

schema = {}

algo_file = nil
headers = []
itemdefs = []

# read itemdef.csv
CSV.foreach(File.join(input_path,'itemdef.csv')) do |row|
  if row[0] == 'name' && schema['name'].nil?
    schema['name'] = row[1]
  else  
    case row[0]
    when 'algFile'
      algo_file = row[1]
    else
      if headers.empty?
        headers = row
      else
        hash = {}
        row.each_with_index do |cell, i|
          hash[headers[i]] = cell
        end
        itemdefs << hash
      end
    end
  end
end

def role(itemdef)
  if itemdef['isDrillDown'] == 'true'
    'context'
  elsif itemdef ['isDataItemValue'] == 'true'
    'parameter'
  else
    'variable'
  end
end

schema['definitions'] = itemdefs.map do |itemdef|
  {
    'label' => itemdef['path'],
    'name' => itemdef['name'],
    'type' => itemdef['type'].downcase,
    'role' => role(itemdef),
    'default' => itemdef['default'],
    'unit' => itemdef['unit'], # needs perUnit integration
  }
end

# Add outputs
implicit_output = true
schema['definitions'] << {
  'label' => 'co2e',
  'name' => 'CO2 equivalent',
  'role' => 'output',
  'unit' => 'kg'
}

# Copy data.csv
File.open(output_name+'.csv', "wb") do |file|
  file << File.read(File.join(input_path,'data.csv'))
end

# Algorithm
schema['algorithm'] = File.read(File.join(input_path,algo_file))
if implicit_output
  schema['algorithm'] = <<EOF
  co2e = eval(#{schema['algorithm'].to_json})
EOF
end
if schema['algorithm'].include?('dataFinder') || schema['algorithm'].include?('profileFinder')
  puts 'WARNING: algorithm uses dataFinder or profileFinder, which are not'
  puts '  supported by this tool. You will need to manually edit the algorithm'
  puts '  to make it work.'
end

File.open(output_name+'.json', "wb") do |file|
  file << JSON.pretty_generate(schema)
end



