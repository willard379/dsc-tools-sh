#!/bin/sh

dsdir=/usr/local/dataspider
relayserverdir=$dsdir/server/system/kernel/modules/webcontainer/META-INF/catalina/webapps/RelayServer
publish_dir=$relayserverdir/publish
proxy_dir=$publish_dir/proxy
icondir=$relayserverdir/images/studio
moduledir=./modules
backeturl=https://s3-ap-northeast-1.amazonaws.com/com.appresso.dsc.modules
backetname=com.appresso.dsc.modules

check_rc() {
  rc=$?
  if [ $rc -ne 0 ]; then
    echo "$1"
    exit $rc
  fi
}

check_patchname() {
  if [ -z "$patchname" ]; then
    echo "引数にパッチ番号を指定するがよい。"
    exit 1
  fi
}

create_download_destination() {
  if [ ! -d "$moduledir/$patchname" ]; then
    mkdir -p $moduledir/$patchname
  fi
}

deploy_server_module() {
  unzip -o $moduledir/$patchname/dsc-server_*.zip -d $dsdir
  check_rc "server モジュールのデプロイに失敗したみたい。"
  rm -f ~/dsc-server_*.zip
  cp $moduledir/$patchname/dsc-server_*.zip ~

  echo "server モジュールデプロイしました。"
  sleep 1
}

deploy_studio_module() {
  rm -rf $publish_dir/Application\ Files $publish_dir/Studio.application 
  unzip -o $moduledir/$patchname/dsc-studio_*_installless.zip -d $publish_dir
  check_rc "ClickOnce 版モジュールのデプロイに失敗したみたい。"
  rm -f ~/dsc-studio_*_installless.zip
  cp $moduledir/$patchname/dsc-studio_*_installless.zip ~
  echo "ClickOnce 版モジュールデプロイしました。"

  sleep 1

  rm -rf $proxy_dir/Application\ Files $proxy_dir/Studio.application
  unzip -o $moduledir/$patchname/dsc-studio_*_install.zip -d $proxy_dir
  check_rc "Proxy ログイン版モジュールのデプロイに失敗したみたい。"
  rm -f ~/dsc-studio_*_install.zip
  cp $moduledir/$patchname/dsc-studio_*_install.zip ~
  echo "Proxy ログイン版モジュールデプロイしました。"

  sleep 1
}

download_modules() {
  if [ "$downloaded" = true ]; then
    return 0
  fi
  patchname=$1
  check_patchname
  create_download_destination
  aws s3 cp s3://$backetname/$patchname/ $moduledir/$patchname --recursive
  check_rc "S3につながらないっぽい。"
  downloaded=true
}

check_server_module() {
  if [ ! -f $moduledir/$patchname/dsc-server_*.zip ]; then
    echo "server モジュールがないみたい。"
    exit 1
  fi
}

check_studio_module() {
  if [ ! -f $moduledir/$patchname/dsc-studio*_installless.zip ]; then
    echo "ClickOnce版モジュールがないみたい。"
    exit 1
  fi
  if [ ! -f $moduledir/$patchname/dsc-studio*_install.zip ]; then
    echo "Proxyログイン版モジュールがないみたい。"
    exit 1
  fi
}

server() {
  download_modules $1
  check_server_module
  deploy_server_module
}

studio() {
  download_modules $1
  check_studio_module
  deploy_studio_module
}

icon() {
  if [ -z "$1" ]; then
    echo "第二引数にURLを指定してください"
    exit 1
  fi
  wget -O Studio.ico $1 > /dev/null 2>&1
  check_rc "URLちゃいます。"
  if [ ! -f $icondir/Studio.ico.bak ]; then
    mv $icondir/Studio.ico $icondir/Studio.ico.bak
  fi
  mv Studio.ico $icondir/Studio.ico
}

case $1 in
  server)
    server $2
    ;;
  studio)
    studio $2
    ;;
  all)
    server $2
    studio $2
    ;;
  icon)
    icon $2
    ;; 
  *)
    echo "$1ってなんやねん！"
    ;;
esac
