# gemの読み込み
require 'sinatra'
require 'pg'
require "fileutils"
require 'digest'

# 開発環境のみで使用
require 'sinatra/reloader'
require 'pry'

enable :sessions

# DB接続
client = PG::connect(
    :host => ENV.fetch("DB_HOST", "localhost"),
    :user => ENV.fetch("DB_USER","postgres"),
    :password => ENV.fetch("DB_PASSWORD",""),
    :dbname => ENV.fetch("DB_NAME","board")
)

get '/' do
    redirect 'login'
end

###############################
## サインアップ(ユーザー新規登録) ##
###############################
# サインアップフォーム画面を表示
get '/signup' do
    if session[:user]
        redirect '/boards/new'
    end
    return erb :signup
end
# フォームに入力した情報をDBへ記録
post '/signup' do
    name = params[:name]
    email = params[:email]
    password = params[:password]
    password_digest = Digest::SHA512.hexdigest(password)
    client.exec_params(
        "INSERT INTO users (name, email, password) VALUES ($1, $2, $3)",
        [name, email, password_digest]
    )
    # ついでにログイン処理
    user = client.exec_params(
        "SELECT * from users WHERE email = $1 AND password = $2 LIMIT 1",
        [email, password_digest]
    ).to_a.first
    session[:user] = user
    return redirect '/boards/new'
end


######################
## ログイン・ログアウト ##
######################
# ログインフォーム画面の表示
get '/login' do
    if session[:user]
        redirect '/boards/new'
    end
    return erb :login
end
# フォームに入力した情報をDBへ記録
post '/login' do
    email = params[:email]
    password = params[:password]
    password_digest = Digest::SHA512.hexdigest(password)
    user = client.exec_params(
        "SELECT * FROM users WHERE email = $1 AND password = $2 LIMIT 1",
        [email, password_digest]
    ).to_a.first
    if user.nil?
        return redirect '/signup'
    else
        session[:user] = user
        return redirect '/boards/new'
    end
end
# ログアウト
delete '/logout' do
    session[:user] = nil
    return redirect '/login'
end


################
## 掲示板の作成 ##
################
# 掲示板の作成画面を表示
get '/boards/new' do
    # 全ての掲示板のリンクを表示
    @boards = client.exec_params("SELECT * from boards").to_a
    return erb :new_board
end
# フォームに入力した情報をDBへ記録
post '/boards' do
    name = params[:name]
    client.exec_params(
        "INSERT INTO boards (name) VALUES ($1)",
        [name]
    )
    new_board = client.exec_params(
        "SELECT * from boards WHERE name = $1",
        [name]
    ).to_a.first
    return redirect "/boards/#{new_board["id"]}"
end


#########
## 投稿 ##
#########
# 掲示板ごとの投稿内容の画面を表示
get '/boards/:id' do
    @board_id = params[:id]
    @board = client.exec_params(
        "SELECT * from boards WHERE id = $1 LIMIT 1",
        [@board_id]
    ).to_a.first
    @posts = client.exec_params(
        "SELECT * from posts WHERE board_id = $1",
        [@board_id]
    ).to_a
    return erb :board
end
# フォームに入力した情報をDBへ記録
post '/boards/:id/posts' do
    board_id = params[:id]
    name = session[:user]["name"]
    content = params[:content]
    image_path = ''
    if !params[:image].nil?
        tempfile = params[:image][:tempfile]
        save_to = "./public/images/#{params[:image][:filename]}"
        FileUtils.mv(tempfile, save_to)
        image_path = params[:image][:filename]
    end
    client.exec_params(
        "INSERT INTO posts (name, content, image_path, board_id) VALUES ($1, $2, $3, $4)",
        [name, content, image_path, board_id]
    )
    return redirect "/boards/#{board_id}"
end