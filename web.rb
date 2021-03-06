require 'rubygems'
require 'sinatra'
require 'pivotal-tracker'

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] ||= 'super secret'
  require 'rack-ssl-enforcer'
  use Rack::SslEnforcer, :except_environments => 'development'
end

PivotalTracker::Client.use_ssl = true

get '/' do
  if !session[:token].nil?
    PivotalTracker::Client.token = session[:token]
    projects = PivotalTracker::Project.all
    session[:projects] = projects
    redirect "/project/#{projects[0].id}"
  else
    erb :signin
  end
end

post '/signin' do
  token = PivotalTracker::Client.token(params[:username], params[:password])
  session[:token] = token
  session[:username] = params[:username]
  redirect '/'
end

get '/project/:project' do |pid|
  PivotalTracker::Client.token = session[:token]
  projects = PivotalTracker::Project.all
  if project = projects.find { |project| project.id.to_s == pid }
    stories = project.stories.all(:story_type => ['feature'], :current_state => ['unstarted', 'accepted', 'started', 'rejected'], :includedone => 'true')
    erb :projects, :locals => { :projects => session[:projects], :stories => stories, :pid => pid, :username => session[:username] }
  else
    "Unable to retrieve project #{pid}"
  end
end

post '/updateStory' do
  PivotalTracker::Client.token = session[:token]
  projects = PivotalTracker::Project.all
  if project = projects.find { |project| project.id.to_s == params[:pid] }
    story =  project.stories.find(params[:sid])
    if story.nil?
      "Unable to retrieve story #{sid} <br /> #{story.inspect}"
    else
      labels = ''
      feedback = '-1'
      if !story.labels.nil?
        story.labels.split(',').each do |label|
          if !label.nil? && !label.empty?
            if !label.include? 'bv-'
              labels << ',' if !labels.empty?
              labels <<  label
            end
          end
        end
      end
      if !params[:bv].nil?
        labels << ',' if !labels.empty?
        labels << 'bv-' + params[:bv]
        feedback = params[:bv]
      end
      updateRes = story.update( :labels => labels )
      feedback
    end
  else
    "Unable to retrieve project #{params[:id]}"
  end
end
