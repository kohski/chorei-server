# README
[![ruby version](https://img.shields.io/badge/Ruby-v2.5.1-green.svg)](https://www.ruby-lang.org/ja/)
[![rails version](https://img.shields.io/badge/Rails-v5.2.3-brightgreen.svg)](http://rubyonrails.org/)
[![codecov](https://codecov.io/gh/kohski/chorei-server/branch/master/graph/badge.svg)](https://codecov.io/gh/kohski/chorei-server)
[![CircleCI](https://circleci.com/gh/kohski/chorei-server.svg?style=svg)](https://circleci.com/gh/kohski/chorei-server)

## アプリ名： Chorei
アプリURL: https://www.chorei.site
API Document URL: https://api.chorei.site/api-docs
フロント側github: https://github.com/kohski/chorei-client

動作確認用アカウント
- メールアドレス: sample1@test.com
- パスワード: password

## アプリ概要
共働き世帯の家事の管理をするためのアプリケーションです。
ついつい家事がおろそかになる原因・対策として、
1. 誰がやるか曖昧
  => groupを作って担当者を決定
2. いつやるかわからない
  => Googleカレンダーのようにスケジューリングする機能
3. どうやるかわからない
  => クックパッドのように手順を細分化して登録しマニュアル化する機能
     マニュアルを公開設定して共有できる機能
を実施しました。

## 使用技術
全体の構成
![ChoreiForSlide (4)](https://user-images.githubusercontent.com/39625567/61593561-f372eb00-ac1b-11e9-9aa4-6d25d7b553f3.png)
モバイルアプリやデスクトップアプリ対応も見越してRailsをAPIとして使用
フロントエンドはNuxt.jsで作成

- インフラ関連
  - Route53 / ELB / ACM によるHTTPS化
  - EC2インスタンスを2つ用意して、それぞれにプロジェクトをデプロイ
  - RDS + PostgresqlでDBを切出し
- バックエンド
  - Rails APIモード
  - 'devise-token-auth'によるToken認証
  - 'rack-cors'によるCORS対応
  - code-covによるテストカバレッジ算出(98.49%)
  - swaggerによるweb APIドキュメント作成
- フロントエンド
  - nuxt.js
  - axiosによるHTTP通信
  - 画像はbase64urlにencodeして、JSONに含めて送受信
  - UI FrameWorkはvuetifyを使用

## バージョン情報
  - インフラ
    - AWS EC2
    - AWS ELB
    - AWS ACM
    - AWS Route53
    - AWS RDS
  - サーバーサイド
    - Ruby 2.5.1
    - Ruby on Rails 5.2.3(apiモード)
  - データベース
    - Postgresql 11.3
  - フロントエンド
    - nuxt.js 2.8.0
    - vuetify 1.5.14
    - vuex 3.1.1
## ER図
![2019-07-20 1 18 46](https://user-images.githubusercontent.com/39625567/61593512-4ac48b80-ac1b-11e9-92b2-dd831afe65cf.png)
