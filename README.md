# Backlog Streamer

[![Buildhive Status](https://buildhive.cloudbees.com/job/cynipe/job/backlog-streamer/badge/icon)](https://buildhive.cloudbees.com/job/cynipe/job/backlog-streamer/) [![Travis Status](https://secure.travis-ci.org/cynipe/backlog-streamer.png)](http://travis-ci.org/cynipe/backlog-streamer)

Backlogのタイムラインの更新をYammerにポストしてくれるDaemon

## リリースノート

### 0.0.5
* plugin機構追加
* fluent-plugin追加
* 課題の作成者、担当者を通知の是非に関わらずに常に含めるようにした

### 0.0.4
* config.ymlのyammer::notifies_toを設定することで通知する人を絞れるようにした([#7](https://github.com/cynipe/backlog-streamer/issues/7))
* 同じ課題に対する更新の場合はスレッドに投稿するようにした([#5](https://github.com/cynipe/backlog-streamer/issues/5))

### 0.0.3
* 更新者と担当者が同じでもccされてしまう([#3](https://github.com/cynipe/backlog-streamer/issues/3))

### 0.0.2
* 課題を辿って登録者、担当者をmentionに利用するようにした([#1](https://github.com/cynipe/backlog-streamer/issues/1))
* faraday/utils.rbで出ていた正規表現の警告を抑制([#2](https://github.com/cynipe/backlog-streamer/issues/2))

### 0.0.1
* Timelineの更新をYammerに通知出来るようにした
* [担当者: foo]とあった場合に@fooとしてmentionを飛ばすようにした

