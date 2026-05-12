# Day1

## 読んだファイル
- config/routes.rb
---
## このファイルの役割
- URLとControllerを紐付けるファイル
- アプリ全体の機能一覧を管理している
---
## 理解したこと
- root to: は最初に開くページ
- resources はCRUDルーティングを自動生成する
- member は特定ID用URL
- collection は一覧系URL
---
## 処理の流れ（超重要）
- ユーザーがURLアクセス
↓
- routes.rb が Controller を呼ぶ
↓
- Controller が処理を実行
↓
- View を表示する
---
## 実際にやったこと
- routes.rb に日本語コメント追加
- public_index の動きを確認
- reviews のネスト構造を確認
---
## 感想



---
## 次に読むファイル
- homes_controller.rb