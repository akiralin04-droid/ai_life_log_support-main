# Day6-2

## 読んだ機能
キャンペーン機能（campaigns）

---

## 読んだファイル
- config/routes.rb
- app/controllers/campaigns_controller.rb
- app/views/campaigns/show.html.erb
- app/models/campaign.rb
- db/schema.rb（campaignsテーブル）
---

## 各ファイルの役割
- routes.rb：
GET /campaigns/:id のみ公開。show以外のルートは存在しない
- campaigns_controller.rb：
URLの:idからキャンペーンを取得してviewに渡す
- show.html.erb：
キャンペーン情報を表示し、参加ボタンでAIインタビューへ誘導する
- campaign.rb：
管理者・レビュー・AIインタビューとの関連を定義する
- schema.rb：
企業名・タイトル・説明・AI指示文・終了日・公開フラグを持つ
---

## 重要ポイント
- only: [:show] はユーザーがキャンペーンを作成・編集・削除できないことを表す。管理者だけが作る設計
- allow_unauthenticated_access は未ログインでも通す設定。Rails 8の書き方
- Campaign.find はスコープなし。キャンペーンは誰のものでもない共有リソースのため絞り込み不要
- link_to + data: { turbo_method: :post } は見た目はリンクだがPOSTで送信する
- createになるのはturbo_methodの設定ではなく、POST + /ai_interviews というルーティング規則で決まる
- ai_prompt カラムはユーザーには見せない。キャンペーンごとにAIへの指示を変えるために使う
- is_active フラグで削除せずに非公開にする設計
---

## 新しく出てきた概念
- allow_unauthenticated_access：Rails 8の未ログイン許可の書き方
- simple_format：テキストの改行をHTMLの<br>に変換するRailsヘルパー
- data: { turbo_method: :post }：link_toをPOSTリクエストに変換するTurboの仕組み
---

## 処理の流れ
【キャンペーン閲覧】
GET /campaigns/:id（未ログインでもOK）
↓
allow_unauthenticated_access で通過
↓
Campaign.find(params[:id])
↓
show.html.erb 表示

【キャンペーン参加】
参加ボタン押下
↓
POST /ai_interviews（campaign_id: @campaign.id をパラメータで送信）
↓
ai_interviews#create へ（Day6の処理へ合流）
↓
ai_prompt の内容をもとにAIが質問を生成


---

## ファイルの繋がり
routes.rb
↓ GET /campaigns/:id だけを公開

campaigns_controller.rb（allow_unauthenticated_access → show）
↓ Campaign.find でキャンペーンを取得

show.html.erb
↓ 参加ボタンでPOST /ai_interviews に送信

ai_interviews_controller.rb#create（Day6の処理へ）
↓ campaign_id・ai_promptを使ってAIインタビューを開始

ai_interviews → reviews（完了後にレビュー保存）
---

## Railsが自動でやっていること
- resources :campaigns, only: [:show] でshow用のルートとパスヘルパーだけ生成
- POST /ai_interviews をルーティング規則でcreateアクションに振り分ける
- simple_format が改行を<br>に変換してHTMLとして整形

---


## 次に読む機能
レビュー機能（reviews）
