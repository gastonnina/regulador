#!/bin/bash
sshpass -p 'egpp' /usr/bin/ssh root@192.168.122.100 'mkdir -p /usr/local/bin/tools_regulador'
sshpass -p 'egpp' /usr/bin/scp regulador.sh root@192.168.122.100:/usr/local/bin/
sshpass -p 'egpp' /usr/bin/scp -r tools_regulador root@192.168.122.100:/usr/local/bin/
sshpass -p 'egpp' /usr/bin/ssh root@192.168.122.100 'chmod +x /usr/local/bin/regulador.sh'
sshpass -p 'egpp' /usr/bin/ssh root@192.168.122.100 '\
regulador.sh instalar
'

# nodemon --watch . -e sh --exec "./execute_regulador.sh"