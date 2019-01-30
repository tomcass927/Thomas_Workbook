require 'rubygems'
require 'sinatra'
require 'active_record'
require 'digest/md5'
require 'date'
require 'mysql2'
Dir["models/*.rb"].each {|file| require_relative file }



class AcquireView < Sinatra::Base

  USERS = {
    'tom' => 'PASSWORD HERE',
    'noel' => 'PASSWORD HERE',
    'matt' => 'PASSWORD HERE',
  }
  ActiveRecord::Base.establish_connection(
    adapter: 'mysql2',
    host:  'DB Endpoint Locaition HERE',
    user:  'tom',
    password:  'PASSWORD',
    database:  'DATABASENAME HERE'
  )

DATABASE_HOST = 'DATABASEHOST HERE'
  DATABASE_USER = 'tom'
  DATABASE_NAME = 'DB USER NAME HERE'
  DATABASE_PASS = 'DB PASS HERE'


  configure do
    enable :sessions
  end

  helpers do
    def username
      session[:identity] ? session[:identity] : 'Hello stranger'
    end
  end

  before '/secure/*' do
    unless session[:identity]
      session[:previous_url] = request.path
      @error = 'Sorry, you need to be logged in to visit ' + request.path
      halt erb(:login_form)
    end
  end

  get '/' do
    redirect '/secure/recentreports'
  end

  get '/login/form' do
    erb :login_form
  end

  post '/login/attempt' do
    if user_exists?
      session[:identity] = params['username']
      where_user_came_from = session[:previous_url] || '/'
      redirect to where_user_came_from
    else
      redirect '/login/form'
    end
  end

  get '/logout' do
    session.delete(:identity)
    erb "<div class='alert alert-message'>Logged out</div>"
  end

  get '/secure/allreports' do
    @campaigns = Campaign.order('StartDate DESC').limit(250)
    erb :run
  end

  get '/secure/recentreports' do
    @send_emails = params[:send_emails].present?
    @campaigns = Campaign.where("StartDate < ?", Date.today).limit(100).order('StartDate DESC')
    erb :run
  end


  get '/secure/history' do
    @send_emails = params[:send_emails].present?

    if params[:page].present?
      limit = params[:limit].present? ? params[:limit].to_i : 25
      @start_point = params[:page].to_i * limit
      @end_point = @start_point + limit - 1
    else
      @start_point = params[:start].to_i
      @end_point = params[:end].to_i
    end

    if @start_point && @end_point
      @campaigns = Campaign.where("StartDate < ?", Date.today).order('StartDate DESC')
      erb :history
    else
      erb "Set start=X and end=X"
    end

  end

 get '/secure/newly_added' do
    @campaigns = Campaign.order('StartDate DESC').limit(30)
    erb :newly_added
  end

 get '/secure/startingtoday' do
    @campaigns = Campaign.where("StartDate = ?", Date.today).all
    erb :run
  end


 get '/secure/update_db' do


     `mysqldump ALAppDB -u databoxreader -h (AWS_DB_HOST_ENDPOINT_LOCATION.us-west-2.rds.amazonaws.com) -(password HERE) --single-transaction=TRUE > export_sql/first_db_full_export.sql`

     `mysqldump ALAppDB FacebookReportSnapshot -u databoxreader -h (AWS_DB_HOST_ENDPOINT_LOCATION.us-west-2.rds.amazonaws.com) -(password HERE) --single-transaction=TRUE --no-create-info --complete-insert > export_sql/first_db_only_one_table.sql`

     `mysql ALAppDB2 -u tom -h (AWS_DB_HOST_ENDPOINT_LOCATION.us-west-2.rds.amazonaws.com) -(password HERE) < export_sql/first_db_full_export.sql`

     `sed -n 's/FacebookReportSnapshot/FacebookReportSnapshotHistory/gpw export_sql/first_db_only_one_table_edited.sql' export_sql/first_db_only_one_table.sql`

     `mysql ALAppDB2 -u tom -h (AWS_DB_HOST_ENDPOINT_LOCATION.us-west-2.rds.amazonaws.com) -(password HERE) < export_sql/first_db_only_one_table_edited.sql`

      client = Mysql2::Client.new(:host => DATABASE_HOST, :username => DATABASE_USER, :password => DATABASE_PASS, :database => DATABASE_NAME, :ssl_mode => :disabled, :secure_auth => false)
    @query_tool = client.query("update FacebookReportSnapshotHistory SET HistoricalTimeStamp=NOW() where HistoricalTimeStamp IS NULL;")

    erb 'DatabaseUpdateCompleted'
    

  end

  private
  def user_exists?
    USERS.select { |user,pass| user == params['username'] && pass == Digest::MD5.hexdigest(params['pass'].to_s) }.present?
  end
end
