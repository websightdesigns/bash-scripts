#!/bin/sh

# export.sh
# @author github.com/websightdesigns
# @description Export SQL and uploads directory
 
# configure
wpconfig='wp-config.php'
mysqlconfig=".my.cnf"
debug='0'

###############################
# do not edit below this line #
###############################

# script variables
bold=$(tput bold)
normal=$(tput sgr0)
underline=$(tput smul)
wpdbname=`cat $wpconfig | grep DB_NAME | cut -d \' -f 4`
wpdbuser=`cat $wpconfig | grep DB_USER | cut -d \' -f 4`
wpdbpass=`cat $wpconfig | grep DB_PASSWORD | cut -d \' -f 4`

# check if wpconfig exists
if [ ! -f $wpconfig ]; then
  echo "ERROR: The specified WordPress config file does not exist: $wpconfig"
  echo "Exiting..."
  exit
fi

# check if mysqlconfig exists
if [ ! -f $HOME/$mysqlconfig ]; then
  # mysqlconfig does not exist, create it
  if [ $debug = 1 ]; then
    echo "INFO: Creating the MySQL config file: $HOME/$mysqlconfig"
  fi
  echo "[client$wpdbname]" > $HOME/$mysqlconfig
  chmod 600 $HOME/$mysqlconfig
  echo "  password=$wpdbpass" >> $HOME/$mysqlconfig
else
  # mysqlconfig does exist, check if it already contains the password 
  #echo "INFO: MySQL config file already exists"
  if ! grep -q "\[client$wpdbname\]" "$HOME/$mysqlconfig"; then
    if [ $debug = 1 ]; then
      echo "INFO: Adding password to MySQL config file"
    fi
    echo "[client$wpdbname]" >> $HOME/$mysqlconfig
    echo "  password=$wpdbpass" >> $HOME/$mysqlconfig
  fi
fi

# execute mysql export
if [ $debug = 1 ]; then
  echo "INFO: Exporting MySQL database"
fi
mysqldump --defaults-group-suffix=$wpdbname --defaults-file=$HOME/$mysqlconfig -u $wpdbuser $wpdbname > $wpdbname.sql

# export uploads directory
if [ $debug = 1 ]; then
  echo "INFO: Compressing uploads directory"
fi
tar cf wp-content/uploads.tar wp-content/uploads/
gzip -f wp-content/uploads.tar

# Output Info
echo
echo "${underline}SQL Export${normal}"
echo "$(pwd)/$wpdbname.sql"
echo
echo "${underline}Uploads Export${normal}"
echo "$(pwd)/wp-content/uploads.tar.gz"
echo
echo "${underline}SCP Commands${normal}"
echo "scp summerscorner:$(pwd)/$wpdbname.sql ."
echo "scp summerscorner:$(pwd)/wp-content/uploads.tar.gz ."
echo

# EOF
