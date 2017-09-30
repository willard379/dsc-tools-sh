#!/bin/sh

if [ -z "$1" ]; then
  echo "引数にリポジトリDBとして使うデータベース名を指定してほしいです。"
fi

cat << EOT > /usr/local/dataspider/server/system/conf/database_mgr.properties
type=mysql
jarClassPath=/usr/local/dataspider/mariadb-java-client-1.5.5.jar
url=jdbc:mariadb://repositorydb-mariadb.cis3jmdkfkbo.ap-northeast-1.rds.amazonaws.com:3306/$1
user=root
rawPassword=password
EOT
