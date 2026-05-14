# Day4

## 読んだ機能
- マイページ表示機能
---

## 読んだファイル
- config/routes.rb
- app/controllers/mypages_controller.rb
- app/views/mypages/show.html.erb
- app/models/user.rb
- db/schema.rb
---

## 各ファイルの役割
- routes.rb 
resource :mypage, only: [:show] でGET /mypage を mypages#show に繋ぐ
- mypages_controller.rb 
マイページに必要な全データをインスタンス変数に用意する
- show.html.erb 
カレンダー・統計・タブ4種を描画する
- user.rb 
has_many の関連定義、has_many :through でいいねレビューを取得
- schema.rb 
テーブル構造とカラムの確認
---

## 重要ポイント
- authenticate_user! 
ログイン確認、ensure_correct_user は本人確認
- includes 
N+1問題を防ぐ
- turbo_frame_tag 
サーバーが全HTMLを返し、ブラウザ側のTurboが該当frameだけ差し替える
- weekly_report_id
diaries 側が持つことで未分析判定が1カラムで済む
---

## 新しく出てきた概念
- present? 
nil・空文字・空配列をまとめて「中身なし」と判定
- includes 
N+1問題の対策、関連データをまとめて取得
- ransack 
検索条件オブジェクトを作るgem
- group_by 
配列をHashに変換するRubyメソッド
- turbo_frame_tag 
frame内だけ部分更新する仕組み
- button_to vs link_to 
POSTはbutton_to、GETはlink_to
- weekly_report_id の設計 
diaries側が外部キーを持つ理由
---

## 処理の流れ
【マイページ表示】
GET /mypage
↓
authenticate_user!（未ログインなら弾く）
↓
@user = current_user（:idを使わないので本人確認不要）
↓
カレンダー用・タブ用データをインスタンス変数に用意
↓
成功 → show.html.erb を表示

【カレンダー部分更新】
← または → ボタンをクリック
↓
GET /mypage?month=2026-04
↓
@current_month が切り替わり、@diaries_by_date が再取得される
↓
show.html.erb を返す（全体）
↓
Turboが画面を差し替える

【タブ内検索】
検索フォームを送信
↓
GET /mypage?q_diaries[content_cont]=キーワード
↓
ransackが検索条件を処理 → @diaries に結果が入る
↓
show.html.erb を返す（全体）
↓
Turboが "diaries_frame" の中だけ差し替える
---

## ファイルの繋がり
routes.rb
↓  GET /mypage → mypages#show
mypages_controller.rb（authenticate_user! → show）
↓  インスタンス変数を用意して渡す
show.html.erb
↓  @diaries_by_date[date] でカレンダーを描画
↓  turbo_frame_tag でタブ内を部分更新
user.rb（has_many :through でfavoritesを経由してreviewsを取得）
↓  通過したらDBへ
schema.rb（users / diaries / reviews / favorites / weekly_reports）
---

## Railsが自動でやっていること
- resource :mypage 
mypage_path ヘルパーを自動生成
- includes(:review) 
関連データをまとめて取得しN+1を防ぐ
- ransack 
カラム名_cont などの命名規則で検索SQLを自動生成
- group_by 
配列を日付キーのHashに変換（Rubyの機能）
- Turbo 
サーバーから受け取ったHTMLのうち、対応するframe部分だけ差し替える
---


## 次に読む機能
