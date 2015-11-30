require 'yaml'
require 'erb'
require 'awesome_print'
require 'json'

def symbolize(obj)
  case obj
  when Hash
    obj.map { |k, v| [k.respond_to?(:to_sym) ? k.to_sym : k, symbolize(v) ]}.to_h
  when Enumerable
    obj.map { |x| symbolize(x) }
  else
    obj
  end
end

def yaml(file)
  document = IO.read(file)
  content = ERB.new(document).result
  data = symbolize YAML.load(content)
end

def json(data)
  JSON.pretty_generate data
end

#
#
#

def types
  @types ||= yaml("types.yml").map do |key, type|
    type[:parent] = type[:parent].to_sym if type.key? :parent
    [key, type]
  end.to_h
end

def manufacturers
  files = Dir.glob 'manufacturers/*.yml'

  @manufacturers = files.map do |file|
    name = "manufacturer_" + File.basename(file, '.yml')
    data = yaml file

    [ name.to_sym, data ]
  end.to_h
end

def products
  files = Dir.glob 'products/*.yml'

  @products ||= files.map do |file|
    name = "product_" + File.basename(file, '.yml')
    data = yaml file

    if data.key? :manufacturer
      mkey = data.delete :manufacturer
      data[:manufacturer_id] = manufacturers.keys.index(mkey.to_sym) + 1
    end

    [ name.to_sym, data ]
  end.to_h
end

#
#
#

def types_data
  types.map.each_with_index do |entry, index|
    _key, data = entry

    output = {
      id: index+1,
      name: data[:name],
    }

    output[:unit] = data[:unit] if data.key? :unit

    if data.key? :parent
      parent = data[:parent]
      output[:parent_id] = types.keys.index(parent) + 1
    end

    output
  end
end

def manufacturers_data
  manufacturers.map.each_with_index do |entry, index|
    _key, data = entry
    { id: index + 1 }.merge(data)
  end
end

def products_data
  products.map.each_with_index do |entry, index|
    key, data = entry

    {
      id: index+1,

    }.merge(data)
  end
end

File.write 'generated/types.json', json(types_data)
File.write 'generated/manufacturers.json', json(manufacturers_data)
File.write 'generated/products.json', json(products_data)
