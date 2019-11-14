#! /bin/sh

chmod 777 -R ./* 

# you must apt-get install all the software
echo 'you must apt-get install all the software'

echo '----- install start ...'

# check dir
exe_root="/home/share/"
config="/home/share/config/"
log="/home/share/log/"

if [ ! -d "$exe_root" ]; then  
	mkdir "$exe_root"  
fi

if [ ! -d "$config" ]; then
	mkdir "$config"
fi

if [ ! -d "$log" ]; then
	mkdir "$log"
fi

chmod 777 -R "$exe_root"

# rewrite mosquitto config
cp ./other/mosquitto.conf /etc/mosquitto/ -rf

# rewrite apache config
cp ./other/apache2.conf /etc/apache2/ -rf

# rewrite timezone to the BeiJing time
cp ./other/localtime /etc/ -rf

# write logrotate
cp ./other/logrotate_ctl /etc/logrotate.d/ -f

# others install
cp ./other/lua.1 /usr/local/share/man/man1/ -rf
cp ./other/luac.1 /usr/local/share/man/man1/ -rf
cp ./other/lua.nanorc /usr/share/nano/ -rf
cp ./other/ftplugin/* /usr/share/vim/vim74/ftplugin/ -rf
cp ./other/indent/* /usr/share/vim/vim74/indent/ -rf
cp ./other/syntax/* /usr/share/vim/vim74/syntax/ -rf

# main install
cp ./usr/bin/* /usr/bin/ -rf
cp ./usr/lib/* /usr/lib/ -rf
cp ./usr/local/bin/* /usr/local/bin/ -rf
cp ./usr/local/include/* /usr/local/include/ -rf
cp ./usr/local/lib/* /usr/local/lib/ -rf
cp ./usr/local/share/* /usr/local/share/ -rf

# install auto start script
chmod 777 ./my_service.sh
cp ./my_service.sh /etc/init.d/ -f
update-rc.d my_service.sh defaults 90

chmod 777 -R /home/share

#userdel fa

echo ' '
echo '----- install over --------'
echo '----- please reboot it --------'
echo ' '

