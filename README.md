# wsl-development-software-installer

1. GitHub CLIをインストール

```bash
sudo apt -y update
sudo apt -y install gh
```

2. GitHubへログイン
```bash
gh auth login
```

3. インストール用スクリプトを実行
```bash
git clone https://github.com/Taka-yuky/wsl-development-software-installer.git
cd wsl-development-software-installer
source install-script.sh
```

## 補足：gitの設定
```bash
git config --global user.email "you@example.com"
git config --global user.name "Your Name"
```
