# Backlog Streamer

[![Buildhive Status](https://buildhive.cloudbees.com/job/cynipe/job/backlog-streamer/badge/icon)](https://buildhive.cloudbees.com/job/cynipe/job/backlog-streamer/) [![Travis Status](https://secure.travis-ci.org/cynipe/backlog-streamer.png)](http://travis-ci.org/cynipe/backlog-streamer)

Backlogのタイムラインの更新をYammerにポストしてくれるDaemon

## リリースノート

### 0.0.2
* 課題を辿って登録者、担当者をmentionに利用するようにした(#1)
* faraday/utils.rbで出ていた正規表現の警告を抑制(#2)

### 0.0.1
* Timelineの更新をYammerに通知出来るようにした
* [担当者: foo]とあった場合に@fooとしてmentionを飛ばすようにした

