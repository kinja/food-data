require 'yaml'
require 'erb'
require 'awesome_print'
require 'json'

def yaml(file)
  document = IO.read(file)
  content = ERB.new(document).result
  data = YAML.load content
end

def json(data)
  JSON.pretty_generate data
end

def types
  input = yaml "types.yml"

  input.each_with_index.map do |entry, index|
    key, data = entry

    id = index+1
    name = data['name']

    parent_key = data['parent']

    parent_id = input.keys.index(parent_key)
    parent_id += 1 unless parent_id.nil?

    parent = input[parent_key]

    output = {
      id: id,
      name: name
    }

    if not parent_id.nil?
      output[:parent_id] = parent_id
    end

    output
  end
end



File.write 'types.json', json(types)
