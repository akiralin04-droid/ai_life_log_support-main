# Day6

## 読んだ機能
- AIインタビュー機能（ai_interviews / ai_messages）
---

## 読んだファイル
- config/routes.rb
- app/controllers/ai_interviews_controller.rb
- app/controllers/ai_messages_controller.rb
- app/views/ai_interviews/show.html.erb
- app/models/ai_interview.rb
- app/models/ai_message.rb
- db/schema.rb（ai_interviews・ai_messagesテーブル）
---

## 各ファイルの役割
- routes.rb：
ai_interviewsにネストしてai_messagesを定義。finalizeはmember doでIDつきのカスタムルートを追加
- ai_interviews_controller.rb：
インタビューの作成・チャット表示・終了処理（日記orレビューの生成）を担う
- ai_messages_controller.rb：
ユーザーメッセージの保存とOpenAI APIへの会話履歴送信を担う
- show.html.erb：
チャット画面。roleで吹き出しの左右を切り替え。Stimulusで音声入力を制御
- ai_interview.rb：
purpose・statusのenumを定義。user・campaign・diaryと関連付け
- ai_message.rb：
roleのenumを定義。contentの空送信をバリデーションで防ぐ
- schema.rb：
ai_interviewsはpurpose・statusをintegerで保存。ai_messagesはai_interview_idで親と紐づく
---

## 重要ポイント
- purpose カラムの値（enum）が全ての分岐を決めている。日記モードかレビューモードかはここで判断する
- OpenAIには「記憶」がないため、毎回全会話履歴を配列に詰めてAPIに送ることで文脈を保っている
- build + save は失敗を自分でさばきたいとき。create! は失敗したら即止めたいとき
- belongs_to :diary, optional: true がないと、diary_idがnilのインタビューはバリデーション失敗でDB保存できない
- Railsのバリデーションは save 呼び出し時にまず全チェックし、OKならDBへ、NGなら保存しない
- member do で追加したルートはIDつきのURLになる（/ai_interviews/:id/finalize）
- system ロールのメッセージはAIの性格設定。ユーザーには見せずAPIにだけ送る
- data: { disable_with: "..." } でボタンを送信後に自動無効化し、二重送信を防ぐ
---

## 新しく出てきた概念
- params.dig：
ネストしたparamsを途中がnilでもエラーにならず安全に取り出す
- member do：
特定の1件（ID付き）に対してカスタムアクションを追加するルート定義
- Stimulusコントローラー：
data-controller / data-action / data-target の3つでJSとHTMLを繋ぐ
- simple_format：
テキストの改行を <br> に変換するRailsヘルパー
- build：
DBに保存せずメモリ上にオブジェクトを作る。save を呼んで初めてDBに入る
- optional:true：
belongs_to のバリデーションをスキップし、nilでも保存を許可する
- system ロール：
OpenAI APIにおけるAIの性格設定用の特殊なrole
- フェイルセーフ設計：
APIエラー時でもユーザーのデータを守り、手動で対処できる状態にする
---

## 処理の流れ
【AIインタビュー作成】
POST /ai_interviews
↓
purpose・diary_id・campaign_idを保存（create!）
↓
purpose別に最初のメッセージを作成
↓
ai_interview_path へリダイレクト

【チャット画面表示】
GET /ai_interviews/:id
↓
current_user.ai_interviews.find（他人のチャットは弾く）
↓
ai_messages.order(:created_at)
↓
show.html.erb（roleで吹き出し左右を切り替えて表示）

【メッセージ送信】
POST /ai_interviews/:ai_interview_id/ai_messages
↓
ユーザーメッセージを保存（build + save）
↓
user側のメッセージ数を確認
↓
規定回数以上 → finalize_ai_interview_path へリダイレクト
規定回数未満 → 全会話履歴をOpenAIに送ってAI返答を生成 → チャット画面へ

【終了処理（日記モード）】
GET /ai_interviews/:id/finalize
↓
全会話履歴を1つのテキストにまとめる
↓
OpenAIに送って日記を生成
↓
成功 → diary.update!（content上書き）→ diary_pathへ
失敗 → 生データをそのままcontentに入れて保存

【終了処理（レビューモード）】
POST /ai_interviews/:id/finalize
↓
全会話履歴をOpenAIに送ってレビューを生成
↓
成功 → Review.new → reviews/new をrender（ユーザーが確認してから保存）
失敗 → 生データを本文に入れた状態でreviews/new をrender
---

## ファイルの繋がり
routes.rb
↓ URLとコントローラーを繋ぐ（ネスト・member doでfinalize追加）

ai_interviews_controller.rb（create → show → finalize）
↓ purpose別の分岐・OpenAI API呼び出し・日記orレビューへの保存を決定

ai_messages_controller.rb（create）
↓ ユーザーメッセージを保存・全会話履歴をOpenAIに渡してAI返答を生成

show.html.erb
↓ チャット画面（roleで吹き出し切り替え・Stimulusで音声入力・送信フォーム）

ai_interview.rb（model）
↓ enumでpurpose・statusのメソッドを自動生成・4モデルと関連付け

ai_message.rb（model）
↓ enumでroleのメソッドを自動生成・contentのバリデーション

schema.rb（ai_interviewsテーブル・ai_messagesテーブルに保存）
---

## Railsが自動でやっていること
- enum の定義だけで review_creation? などの判定・変更・絞り込みメソッドを生成
- belongs_to の定義だけで @ai_interview.diary.content など関連先へのアクセスを生成
- has_many :ai_messages, dependent: :destroy でai_interview削除時にai_messagesも自動削除
- ネストルートで params[:ai_interview_id] を自動でparamsに追加
- build で ai_interview_id を自動でセット（手動で指定しなくていい）
- belongs_to のバリデーションで関連先レコードの存在を自動チェック
---


## 次に読む機能
- キャンペーン機能