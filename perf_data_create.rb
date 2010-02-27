require 'rubygems'
require 'mongo'
require 'json'

#
# Performance Create Data
#
# Create a building data struture which contains
#
# - building
#   - address
#   - floor
#   - tenent
#     - person
#       - name
#       - ownership
#   - capability
#     - types
#   
#

class Template
  def initialize(template)
    @template = template
  end
  def run(number)
    @template.gsub('#', number.to_s)
  end
  def generate(repeat)

    repeated_template= ""

    repeat.times { |count|

      if (repeated_template.size > 0)
        repeated_template += ","
      end

      repeated_template += run(count)
    }

    repeated_template = "{ \"building\": [#{repeated_template}]}"

    repeated_template
  end
end

class Runner

  attr_reader :json
  
  def build(size)

    template = '{ "name": "eiffel#", "address":{ "street3": "# tower rd" } }'
    @json = Template.new(template).generate(size)
    @data = JSON.parse(@json)
  end

  def run()

    connection = Mongo::Connection.new
    database = connection.db("buildings_many")
    collection = database["building"]

    collection.save(@data)

    connection.close()
  end
end



5.times { |repeat|

  chart="http://chart.apis.google.com/chart?cht=lc&chxl=microseconds&chs=600x400&chxt=x,y,r&chd=t:"
  chart_data=""
  length_data = ""

  600.times { |n|

    if (n % 10 == 0)

      runner = Runner.new

      runner.build(n)

      start = Time.new

      runner.run()

      delta = Time.new - start

      length_data += "," if (length_data.size > 0)
      length_data = "#{length_data}#{(runner.json.size / 1000).to_i}"

      chart_data += "," if (chart_data.size > 0)
      chart_data = "#{chart_data}#{(delta * 1000).to_i}"
    end
  }

  `open "#{chart}#{chart_data}|#{length_data}"`
}



