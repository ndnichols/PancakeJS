require 'rubygems'
require 'httparty'
require 'json'

class Pancake
  include HTTParty
  format :json
  base_uri 'localhost:8080'
  
  def initialize(username, application_name, secret)
    @username = username
    @application_name = application_name
    @secret = secret
  end
  
  def find_lines(regex, offset=0, limit=0, starttime=0, endtime=0) 
    regex = regex.inspect[1..-2]
    Pancake.get("/#{@username}/#{@application_name}", :query=>{:secret=>@secret, :regex=>regex, :offset=>offset, :limit=>limit, :starttime=>starttime, :endtime=>endtime}).parsed_response
  end
  
  def add_lines(lines)
    Pancake.post("/#{@username}/#{@application_name}/append_lines", :query=>{:secret=>@secret, :lines=>JSON.dump(lines)}).parsed_response
  end
  
  def modify_lines(regex, replace_string, offset=0, limit=0) 
    regex = regex.inspect[1..-2] if regex.is_a?(Regexp)
    Pancake.post("/#{@username}/#{@application_name}/modify_lines", :query=>{:secret=>@secret, :regex=>regex, :replace_string=>replace_string, :offset=>offset, :limit=>limit}).parsed_response
  end
  
  def set_tags(regex, tag, offset=0, limit=0)
    regex = regex.inspect[1..-2] if regex.is_a?(Regexp)
    Pancake.post("/#{@username}/#{@application_name}/set_tags", :query=>{:secret=>@secret, :regex=>regex, :tag=>tag, :offset=>offset, :limit=>limit}).parsed_response
  end

  def remove_tags(regex, tag, offset=0, limit=0)
    regex = regex.inspect[1..-2] if regex.is_a?(Regexp)
    Pancake.post("/#{@username}/#{@application_name}/remove_tags", :query=>{:secret=>@secret, :regex=>regex, :tag=>tag, :offset=>offset, :limit=>limit}).parsed_response
  end

  def delete_lines(regex, offset=0, limit=0)
    regex = regex.inspect[1..-2] if regex.is_a?(Regexp)
    Pancake.delete("/#{@username}/#{@application_name}", :query=>{:secret=>@secret, :regex=>regex, :offset=>offset, :limit=>limit}).parsed_response
  end
  
  def replace_lines(lines, offset=0, limit=0)
    Pancake.put("/#{@username}/#{@application_name}", :query=>{:secret=>@secret, :lines=>JSON.dump(lines), :offset=>offset, :limit=>limit}).parsed_response
  end

end

data = ["First to do", 'another to do']

# puts Wondews.post('http://localhost:8080/ndnichols/wondew', :query=>{:ps=>"foo", :lines=>JSON.dump(data)})
# res = Wondews.get('http://localhost:8080/ndnichols/wondew', :query=>{:ps=>'foo', :regex=>'^First'})
# puts res.to_

pancake = Pancake.new('ndnichols', 'wondew', 'b')
# puts pancake.add_lines(['First something again #done', 'and nothing else!', 'third bit!', 'fourth!']).inspect
# puts pancake.set_tags(/.*/, '#done', 1, 2).inspect
# puts pancake.remove_tags(/.*/, '#done', 1, 2).inspect
# puts pancake.modify_lines('^First something again[^#]*', '$& #done ').inspect #adds #done
# puts pancake.modify_lines('^First something again.*?(#done).*?', "$1").inspect #removes #done
puts pancake.find_lines('', 0, 0, 1277842090247, 0).inspect
# puts pancake.delete_lines(/.*/).inspect
# puts pancake.replace_lines(['This', 'is', 'it.'])
