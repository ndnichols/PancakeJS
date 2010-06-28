require 'rubygems'
require 'httparty'
require 'json'

class Pancake
  include HTTParty
  format :json
  base_uri 'localhost:8080'
  
  def initialize(username, application_name, perm_string)
    @username = username
    @application_name = application_name
    @perm_string = perm_string
  end
    
  def find_lines(regex) 
    regex = regex.inspect[1..-2]
    Pancake.get("/#{@username}/#{@application_name}", :query=>{:ps=>@perm_string, :regex=>regex}).parsed_response
  end
  
  def add_lines(lines)
    Pancake.post("/#{@username}/#{@application_name}", :query=>{:ps=>@perm_string, :lines=>JSON.dump(lines)}).parsed_response
  end
  
  def delete_lines(regex)
    regex = regex.inspect[1..-2]
    Pancake.delete("/#{@username}/#{@application_name}", :query=>{:ps=>@perm_string, :regex=>regex}).parsed_response
  end
  
  def replace_lines(lines)
    Pancake.put("/#{@username}/#{@application_name}", :query=>{:ps=>@perm_string, :lines=>JSON.dump(lines)}).parsed_response
  end
end

data = ["First to do", 'another to do']

# puts Wondews.post('http://localhost:8080/ndnichols/wondew', :query=>{:ps=>"foo", :lines=>JSON.dump(data)})
# res = Wondews.get('http://localhost:8080/ndnichols/wondew', :query=>{:ps=>'foo', :regex=>'^First'})
# puts res.to_

pancake = Pancake.new('ndnichols', 'wondew', 'b')
# pancake.add_lines(['First something again', 'and nothing else!'])
# puts pancake.delete_lines(/^First/).inspect
puts pancake.find_lines(/.*/).inspect
# puts pancake.replace_lines(['This', 'is', 'it.'])
