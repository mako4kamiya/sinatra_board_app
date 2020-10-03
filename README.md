# Sinatra Board App

## 「SinatraアプリをHerokuにデプロイしようの会」用のリポジトリ
(CODEBASEプログラミングスクール卒業生向け)
[「SinatraアプリをHerokuにデプロイしよう」の記事](https://makolog.xyz/sinatra-heroku)


### ローカルにクローンする
```
$ git clone https://github.com/mako4kamiya/sinatra_board_app.git
```

### データベースを作成
```
// PostgreSQLクライアントに接続
$ psql

// データベスを作成する（好きな名前をつけてください）
=# CREATE DATABASE 任意のデータベース名

// 下記の3つのテーブルを作成する
CREATE TABLE users (
  id SERIAL NOT NULL PRIMARY KEY ,
  name VARCHAR( 25 ) NOT NULL ,
  email VARCHAR( 50 ) NOT NULL ,
  password VARCHAR(512) NOT NULL ,
  UNIQUE (email)
);

CREATE TABLE boards (
  id SERIAL NOT NULL PRIMARY KEY ,
  name VARCHAR( 25 ) NOT NULL ,
  UNIQUE (name)
);

CREATE TABLE posts(
  id SERIAL NOT NULL PRIMARY KEY,
  name VARCHAR( 25 ) NOT NULL ,
  content TEXT NOT NULL,
  image_path VARCHAR(512),
  board_id INTEGER NOT NULL
);

// psqlを抜けるには
=# \q
```

### 環境変数の設定
```
& export DB_USER=$(whoami)
& export DB_NAME=任意のデータベース名
& export DB_PASSWORD=〇〇〇〇 //password設定をしていたら
```

### Sinatraアプリを起動
```
// さっき環境変数を設定したターミナルで実行する
$ ruby app.rb
```

ローカルでアプリの実行が確認できたら、
[「SinatraアプリをHerokuにデプロイしよう」の記事](https://makolog.xyz/sinatra-heroku)を参考にHerokuにデプロイしてみましょう！
