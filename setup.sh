#!/bin/sh

dsdir=/usr/local/dataspider

check_rc() {
  ret=$?
  if [ "$ret" -ne 0 ]; then
    echo $1
    exit $ret
  fi 
}

# 権限付与
chmod +x ./*.sh

# ロケールの設定
grep -q "LANG=en_US" /etc/sysconfig/i18n
if [ "$?" -eq 0 ]; then
  sed -i -e 's/en_US/ja_JP/' /etc/sysconfig/i18n
  check_rc "ロケールの設定に失敗しました。"
fi

# タイムゾーンの設定
ln -fs /usr/share/zoneinfo/Asia/Tokyo /etc/localtime
check_rc "タイムゾーンの設定に失敗しました。"

# chkconfig の設定
chmod +x dataspider
if [ ! `chkconfig --list dataspider > /dev/null 2>&1` ]; then
  cp dataspider /etc/rc.d/init.d/dataspider
  chkconfig --add dataspider
  check_rc "起動スクリプトの設定に失敗しました。"
fi

echo "できました"
