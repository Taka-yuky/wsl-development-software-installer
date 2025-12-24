# WSLの基本的なコマンド

## 現在のwslのインストール状況を確認する

```bash
wsl --list
```

## インストール可能なディストリビューションを確認する
```bash
wsl --list --online
```
## 名前を指定してWSLの環境へ入る

```bash
wsl -d <Distribution Name>
```

## 名前を指定してWSLの環境をインストール

```bash
wsl --install <Distribution Name> --Name <Env Name>
```
