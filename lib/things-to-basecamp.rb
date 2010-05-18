require "basecamp"
require 'things'

class ThingsToBasecamp

  def initialize(basecamp_url, basecamp_username, basecamp_password)
    basecamp = Basecamp.new(basecamp_url, basecamp_username, basecamp_password)
    things = Things.new()
    
    tasks = find_tasks(things)
    
    tasks.each do |task|
      project = find_project(basecamp, task.parent.title)
      todo_list = find_todo_list(basecamp, project, task) unless project.nil?

      unless todo_list.nil?
        puts "Added '#{task.title}' to #{project.name}"
#       basecamp.create_item(todo_list_id, task.title)
      end  
    end
  end
  
  def find_tasks things
    tasks = things.focus("today").tasks(:completed => false)
    tasks += things.focus("next").tasks(:completed => false)
    tasks += things.focus("inbox").tasks(:completed => false)

    tasks = tasks.select do |task|
      tagged = false
      task.tags.each do |tag|
        tagged = true if tag.split(":").first == "List"
      end
      tagged
    end
  end

  def find_project(basecamp, project_name)
    basecamp.projects.each do |project|
      if project_name == project.name
        return project
      end
    end    
    nil
  end

  def find_todo_list(basecamp, project, task)
    basecamp.lists(project.id).each do |list|
      task.tags.each do |tag|      
        if list.name == tag.split(":").last
          return list
        end
      end
    end
    nil
  end

end
