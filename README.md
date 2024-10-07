Synthesizer V Articulation Scripts
---

## 説明
Synthesizer V用のアーティキュレーションスクリプト集です。以下のスクリプトが含まれます。
 
* オーバーシュート　跳躍後に勢いあまって一瞬音程が行きすぎます
* オーバーシュート + アンダーシュート　行き過ぎた音程を一瞬戻しすぎます
* プレパレーション　跳躍前に一瞬音程が逆方向に動いて勢いをつけます　
* ピッチ遷移遅延　次の音の頭が前の音程に引きずられます
* 微小経過音　跳躍中に一瞬経過音を挟みます
* しゃくりあげ　リリースの瞬間に語尾が上がります
* フォール　リリース時に語尾が下がります
* 庶民のビブラート　音程ではなく音量が揺れるあまりうまくないビブラート
* グロウル　ピッチを高速でランダムに揺らす、がなり声

## 動画
https://x.com/aike1000/status/1593999002223005697  
https://x.com/aike1000/status/1604156215596122114  
https://x.com/aike1000/status/1840261280772567159

## インストール
右上のCodeボタンからDownload ZIPを選んでダウンロード、展開してスクリプトフォルダにコピーしてください。  
  
スクリプトフォルダはWindowsの場合、以下の場所になります。  
C:\Users\（ユーザー名）\Documents\Dreamtonics\Synthesizer V Studio\scripts
  
それぞれのスクリプトは独立しており、依存関係はありません。必要なスクリプトだけインストールすることができます。

## カスタマイズ
スクリプトの先頭にあるパラメーターを変更するとニュアンスを調整することができます。

```lua
local overshootDuration = 50 / 1000  -- 50msec
```

スクリプトの以下の箇所にcategoryの項目を追加すると、階層メニューで表示されます。

変更前
```lua
function getClientInfo()
  return {
    name = SV:T("Transition:Overshoot"),
    author = "aike",
    versionNumber = 1,
    minEditorVersion = 65540
  }
end
```

変更後
```lua
function getClientInfo()
  return {
    category = "Articulation",
    name = SV:T("Transition:Overshoot"),
    author = "aike",
    versionNumber = 1,
    minEditorVersion = 65540
  }
end
```

## ライセンス
Synthesizer V上で本スクリプトを実行して制作した音楽作品等に制限はありません。使用条件もありません、事前事後の連絡・クレジットなども不要です。
  
本スクリプト自体の改変・再配布については以下のライセンスに従ってください。  
Synthesizer V Articulation Scripts are licensed under MIT License.  
Copyright 2022-2024, aike (@aike1000)  

## 履歴
2022.11 最初のバージョン  
2022.12 庶民のビブラート追加  
2024.9 グロウル追加  
