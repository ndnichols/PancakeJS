#Manages conversion to and from a .wondew and .txt file

require '../client/pancake.rb'
require 'ftools'

Username = 'ndnichols'
Secret = 'angeles'

def push_wondew(filename)
  wondew_file = File.open(filename, 'r')
  curr_project = ''
  count = 0
  lines = Array.new
  wondew_file.each do |line|
    line.strip!
    next if line.empty?
    project = line[/(.+?):$/]
    if project
      curr_project = project[/(.+?):$/][0..-2]
      p curr_project
      # break if curr_project == 'Archive'
    else
      line = "#{line[2..-1]} #project(#{curr_project})"
      lines << line
    end
  end
  wondew_file.close
  pancake = Pancake.new(Username, 'wondew', Secret)
  pancake.delete_lines(/.*/)
  lines.each_slice(50) do |lines| 
    pancake.add_lines(lines)
  end
end

def line_for_wondew(wondew)
  done_string = wondew['tags']['done'] ? ' #done' : ''
  "- #{wondew['text']} #{done_string}"  
end

def pull_wondew(filename)
  if not File.exist?(filename) 
    f = File.open(filename, 'w')
    f.close
  end
  filesize = File.stat(filename).size - 42 #-42 to scoot it back so we can read last number at end
  f = File.open(filename, 'r')
  
  f.pos = filesize > -1 ? filesize : 0
  last_updated = (f.read(42) || '')[/\d+$/] || 0
  f.pos = 0
  
  pancake = Pancake.new(Username, 'wondew', Secret)
  new_wondews = pancake.find_lines(:starttime=>last_updated)['results']
  puts "Found #{new_wondews.length} results!"
  return if new_wondews.empty?
  
  new_wondew_hash = Hash.new(Array.new)
  new_wondews.each do |wondew|
    project = wondew['tags']['project']
    new_wondew_hash[project] += [wondew]
  end
  
  puts new_wondew_hash.inspect

  final_lines = Array.new
  last_project = ''
  end_of_today_index = 0
  f.each do |line|
    line.strip!
    project = line[/(.+?):$/]
    if project
      project = project[0..-2] #strip :
      if last_project == 'Today'
        end_of_today_index = final_lines.length - 1
      end
      last_project = project
      final_lines << line
      puts "checking #{project}"
      new_wondew_hash[project].each do |wondew|
        final_lines << line_for_wondew(wondew)
      end
      new_wondew_hash.delete(project)
    else
      final_lines << line
    end
  end  
  f.close
  puts "end_of_today_index is #{end_of_today_index}"
  
  new_projects = Array.new
  new_wondew_hash.each do |project, wondews|
    new_projects << "#{project}:"
    wondews.each { |wondew| new_projects << line_for_wondew(wondew)}
    new_projects << ""
  end
  
  final_lines[end_of_today_index + 1, 0] = new_projects
  
  final_lines[-1] = Time.now.to_i.to_s
  
  File.open(filename, 'w') do |f|
    f.write(final_lines.join("\n"))
  end
  
  puts "Wrote the file!"
end

if __FILE__ == $0
  push_wondew '/Users/nate/Documents/main_todo.wondew'
end