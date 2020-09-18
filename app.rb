# gemの読み込み
require 'sinatra'
require 'pg'
require "fileutils"
require 'digest'

# 開発環境のみで使用
require 'sinatra/reloader'
require 'pry'

enable :sessions

client = PG::connect(
    :host => ENV.fetch("DB_HOST", "localhost"),
    :user => ENV.fetch("DB_USER","postgres"),
    :password => ENV.fetch("DB_PASSWORD",""),
    :dbname => ENV.fetch("DB_NAME","board")
)


get '/signup' do
    return erb :signup
end
  
post '/signup' do
    name = params[:name]
    email = params[:email]
    password = params[:password]
    client.exec_params(
        "INSERT INTO users (name, email, password) VALUES ($1, $2, $3)",
        [name, email, password]
    )
    user = client.exec_params(
        "SELECT * from users WHERE email = $1 AND password = $2 LIMIT 1",
        [email, password]
    ).to_a.first
    session[:user] = user
    return redirect '/posts'
end
  
get '/login' do
    return erb :login
end
  
post '/login' do
    email = params[:email]
    # password = params[:password] 仮
    password = "39a5e04aaff7455d9850c605364f514c11324ce64016960d23d5dc57d3ffd8f49a739468ab8049bf18eef820cdb1ad6c9015f838556bc7fad4138b23fdf986c7"
    user = client.exec_params(
        "SELECT * FROM users WHERE email = $1 AND password = $2 LIMIT 1",
        [email, password]
    ).to_a.first
    # binding.pry
    if user.nil?
        return erb :login
    else
        session[:user] = user
        return redirect '/posts'
    end
end
  
delete '/logout' do
    session[:user] = nil
    return redirect '/login'
end

get '/posts' do
    if session[:user].nil?
        return redirect '/login'
    end
    @posts = client.exec_params("SELECT * from posts").to_a
    return erb :posts
end
  
post '/posts' do
    user_id = session[:user]['id'] #仮
    board_id = "1" #仮
    content = params[:content]
    image_path = ""
    if !params[:image].nil?
        # tempfile = params[:image][:tempfile]
        # save_to = "./public/images/#{params[:image][:filename]}"
        # FileUtils.mv(tempfile, save_to)
        image_path = params[:image][:filename]
    end
    # binding.pry
    client.exec_params(
        "INSERT INTO posts (user_id, board_id, content, image_path) VALUES ($1, $2, &3, &4)",
        [content, image_path]
    )
    redirect '/posts'
end


get '/boards/new' do
    return erb :new_board
end