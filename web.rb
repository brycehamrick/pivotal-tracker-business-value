require 'rubygems'
require 'sinatra'
require 'pivotal-tracker'

configure do
  enable :sessions
  set :session_secret, ENV['SESSION_SECRET'] ||= 'super secret'
#  require 'rack-ssl-enforcer'
#  use Rack::SslEnforcer
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
  redirect '/'
end

get '/project/:project' do |pid|
  PivotalTracker::Client.token = session[:token]
  project = PivotalTracker::Project.find(pid)
  stories = project.stories.all(:story_type => ['feature'], :current_state => ['unstarted', 'accepted', 'started', 'rejected'], :includedone => 'true')
  "Welcome to Project #{pid}"
  #erb :projects, :locals => { :projects => session[:projects], :stories => stories }
end
