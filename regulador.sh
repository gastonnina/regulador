#!/bin/bash
## Usage: regulador [options] ARG1
##
## echo -e "\e[ 0;33;40motro  \e[m"
## Options:
##   -h, --help    Display this message.
##    -n            Dry-run; only show what would be done.
## https://misc.flogisoft.com/bash/tip_colors_and_formatting
##

MY_PATH="`dirname \"$0\"`"

# Default color map
export C_NONE=''
export C_BLACK='\e[0;30m'
export C_RED='\e[0;31m'
export C_GREEN='\e[0;32m'
export C_BROWN='\e[0;33m'
export C_BLUE='\e[0;34m'
export C_PURPLE='\e[0;35m'
export C_CYAN='\e[0;36m'
export C_LIGHT_GREY='\e[0;37m'
export C_DARK_GREY='\e[1;30m'
export C_LIGHT_RED='\e[1;31m'
export C_LIGHT_GREEN='\e[1;32m'
export C_YELLOW='\e[0;33m'
export C_LIGHT_BLUE='\e[1;34m'
export C_LIGHT_PURPLE='\e[1;35m'
export C_LIGHT_CYAN='\e[1;36m'
export C_WHITE='\e[1;37m'
export C_DEFAULT='\e[0m'
export S_CHECK=$C_GREEN'✔️'$C_DEFAULT
export S_QUESTION=$C_GREEN'❓'$C_DEFAULT
export S_BACKUP=$C_GREEN'✅'$C_DEFAULT


# para que no pida promt en local
red_internet='enp1s0'
red_privada='enp7s0'

# Requerimos variables guardadas
if [ -f $MY_PATH"/tools_regulador/session" ]; then
    $MY_PATH/tools_regulador/session
fi

usage() {
  echo -e $C_YELLOW"Uso:"$C_DEFAULT
	echo -e "  regulador [opciones] [argumentos]"
  echo
  echo -e $C_YELLOW"Opciones: $C_DEFAULT"
  echo -e $C_GREEN"   -h, --help, --ayuda     $C_DEFAULT Despliega mensaje de ayuda"
  echo
  echo -e $C_YELLOW"Comandos válidos: $C_DEFAULT"
  echo -e $C_YELLOW"  red              $C_DEFAULT Ayuda a configurar la red."
  echo -e $C_YELLOW"  instalar         $C_DEFAULT Instala servicios necesarios (Squid, e2Guardian)."
  echo -e $C_YELLOW"  certificado      $C_DEFAULT Crea Certificado y Reinicia."
  echo -e $C_YELLOW"  reinicia         $C_DEFAULT Aplica nuevas reglas y Reinicia (Squid, e2Guardian)."
  
	echo
	echo -e "\e[1mAutor:$C_DEFAULT Gaston Nina \e[34m http://gastonnina.com $C_DEFAULT"
}

f_message(){
    echo -e ""
    echo -e $1
    echo -e ""  
}

f_intalar_squid(){
  if [ ! -f /etc/squid/squid.conf ]; then
    f_message "2A. Instalamos SQUID"
    apt install squid -y
  fi

  if [ ! -f /etc/squid/squid.conf.bk ]; then
    f_message $S_BACKUP" 2B. Sacamos backup de $C_PURPLE /etc/squid/squid.conf"$C_DEFAULT
    cp /etc/squid/squid.conf  /etc/squid/squid.conf.bk
  fi
  
  f_message $S_CHECK" 3. Copiamos configuracionn base $C_PURPLE cat $MY_PATH"/tools_regulador/squid.conf" > /etc/squid/squid.conf"$C_DEFAULT

  cat $MY_PATH"/tools_regulador/squid.conf" > /etc/squid/squid.conf

  f_message $S_CHECK" 4. Reiniciamos squid (Puede llevar un par de minutos 💤) $C_PURPLE systemctl restart squid"$C_DEFAULT

  systemctl restart squid

  f_message $S_CHECK" 5. Verificamos SQUID esta corriendo con $C_PURPLE ss -lntp | grep '3128\|3129'"$C_DEFAULT

  ss -lntp | grep '3128\|3129'
}

f_instalar_e2guardian(){
  if [ ! -f /etc/e2guardian/e2guardian.conf ]; then
    f_message $S_CHECK" 6A. Instalamos e2guardian"
    apt-get install $MY_PATH"/tools_regulador/e2debian_buster_V5.3.4_20200130.deb"
    apt-get install -f
  fi

  if [ ! -f /etc/e2guardian/e2guardian.conf.bk ]; then
    f_message $S_BACKUP" 6B. Sacamos backup de $C_PURPLE /etc/e2guardian/e2guardian.conf"$C_DEFAULT
    cp /etc/e2guardian/e2guardian.conf  /etc/e2guardian/e2guardian.conf.bk
    cp /etc/e2guardian/e2guardianf1.conf  /etc/e2guardian/e2guardianf1.conf.bk
    cp /etc/e2guardian/lists/bannedurllist /etc/e2guardian/lists/bannedurllist.bk
  fi

  f_message $S_CHECK" 7. Descomentamos $C_PURPLE cat /etc/e2guardian/e2guardian.conf | grep 'proxyip\|proxyport'"$C_DEFAULT
  # Descomentamos lineas en archivo
  sed -i 's/#proxyip = 127.0.0.1/proxyip = 127.0.0.1/g' /etc/e2guardian/e2guardian.conf
  sed -i 's/#proxyport = 3128/proxyport = 3128/g' /etc/e2guardian/e2guardian.conf
  cat /etc/e2guardian/e2guardian.conf | grep 'proxyip\|proxyport'

  # agregamos nuestras reglas
  f_message $S_CHECK" 8. Copiamos nuestras reglas a $C_PURPLE $MY_PATH"/tools_regulador/bannedurllist" > /etc/e2guardian/lists/bannedurllist"$C_DEFAULT
  cat $MY_PATH"/tools_regulador/bannedurllist" > /etc/e2guardian/lists/bannedurllist

  f_message $S_CHECK" 9. Reiniciamos e2guardian $C_PURPLE systemctl restart e2guardian"$C_DEFAULT
  systemctl restart e2guardian

  f_message $S_CHECK" 10. Revisamos puertos de e2guardian $C_PURPLE ss -lntp | grep '8443\|8080'"$C_DEFAULT
  ss -lntp | grep '8443\|8080'

  # Siguientes lineas para habilitar hombre en el medio MITM
  if [ ! -f /etc/ssl/openssl.cnf.bk ]; then
    f_message $S_BACKUP" 10A. Para implementar MITM Sacamos backup de $C_PURPLE /etc/ssl/openssl.cnf"$C_DEFAULT
    cp /etc/ssl/openssl.cnf  /etc/ssl/openssl.cnf.bk
  fi
  # Se reemplaza basicConstraints a TRUE
  sed -i 's/basicConstraints=CA:FALSE/basicConstraints=CA:TRUE/g' /etc/ssl/openssl.cnf
  
  f_message $S_CHECK" 11. Creamos carpeta para cerificados de e2guardian"$C_DEFAULT
  mkdir -p /etc/e2guardian/ssl /etc/e2guardian/generatedcerts
  chown e2guardian:e2guardian /etc/e2guardian/generatedcerts
  chown e2guardian:e2guardian /etc/e2guardian/ssl

  # Generamos por primera vez los certifiados
  f_set_certificados
  
  # Adecuams archivo de configuracion de e2guardian para trabajar con SSL
  f_message $S_CHECK" 12. Adecuamos archivo de configuracion de e2guardian para trabajar con SSL"$C_DEFAULT
  sed -i 's/enablessl = off/enablessl = on/g' /etc/e2guardian/e2guardian.conf
  sed -i "s/#sslcertificatepath = '' /sslcertificatepath ='\/etc\/ssl\/certs\/' /g" /etc/e2guardian/e2guardian.conf
  sed -i "s/#cacertificatepath = '\/home\/e2\/e2install\/ca.pem'/cacertificatepath = '\/etc\/e2guardian\/ssl\/my_rootCA.crt'/g"  /etc/e2guardian/e2guardian.conf
  sed -i "s/#caprivatekeypath = '\/home\/e2\/e2install\/ca.key'/caprivatekeypath = '\/etc\/e2guardian\/ssl\/private_root.pem'/g"  /etc/e2guardian/e2guardian.conf
  sed -i "s/#certprivatekeypath = '\/home\/e2\/e2install\/cert.key'/certprivatekeypath = '\/etc\/e2guardian\/ssl\/private_cert.pem'/g"  /etc/e2guardian/e2guardian.conf
  sed -i "s/#generatedcertpath = '\/home\/e2\/e2install\/generatedcerts\/'/generatedcertpath = '\/etc\/e2guardian\/ssl\/generatedcerts\/'/g"  /etc/e2guardian/e2guardian.conf
  
  # Adecuams archivo de configuracion de e2guardianf1 para trabajar con SSL
  sed -i 's/sslmitm = off/sslmitm = on/g' /etc/e2guardian/e2guardianf1.conf  
}

f_set_certificados(){
# Se pude modularizar ya que necistaremos crear certificado para renovar
  f_message $S_CHECK" 🔑. Creamos Certificados $C_PURPLE openssl genrsa 4096 > private_root.pem"$C_DEFAULT
  cd /etc/e2guardian/ssl/
  # eliminamos archivos anteriores
  rm -rfv ./*

  openssl genrsa 4096 > private_root.pem
  # creamos certificado con datos pordefecto
  openssl req -new -x509 -days 3650 -sha256 -key private_root.pem \
  -subj "/C=BO/ST=La Paz/L=Murillo/O=Regulador/CN=www.regulador.com" -out my_rootCA.crt

  openssl genrsa 4096 > private_cert.pem
  # Convertir el archivo my_rootCA.crt en formato .der para que pueda ser instalado en el navegador del cliente.
  openssl x509 -in my_rootCA.crt -outform DER -out my_rootCA.der

  f_get_certificados
}

f_get_certificados(){
  f_message $S_CHECK" 📢 Copie el certificado para instalar a su navegador$C_YELLOW (💭 TIP: Filezilla) $C_PURPLE /tmp/my_rootCA.der"$C_DEFAULT
  cp /etc/e2guardian/ssl/my_rootCA.der /tmp/
}

f_reinicia(){
  f_message $S_CHECK" R1. Copiamos nuestras reglas a $C_PURPLE $MY_PATH"/tools_regulador/bannedurllist" > /etc/e2guardian/lists/bannedurllist"$C_DEFAULT
  cat $MY_PATH"/tools_regulador/bannedurllist" > /etc/e2guardian/lists/bannedurllist

  f_message $S_CHECK" R2. Reiniciamos squid (Puede llevar un par de minutos 💤) $C_PURPLE systemctl restart squid"$C_DEFAULT

  systemctl restart squid

  f_message $S_CHECK" R3. Reiniciamos e2guardian $C_PURPLE systemctl restart e2guardian"$C_DEFAULT
  
  systemctl restart e2guardian
}

f_red(){
  if [ ! -f /etc/network/interfaces.bk ]; then
    f_message $S_BACKUP" 1A. Sacamos backup de $C_PURPLE /etc/network/interfaces"$C_DEFAULT
    cp /etc/network/interfaces  /etc/network/interfaces.bk
  fi

  # Si el texto 'RED RESTRINGIDA' ya existe se restaura de backup
  interfaz_reemplazada=$(cat /etc/network/interfaces | grep 'RED RESTRINGIDA' | wc -l)
  if [ "$interfaz_reemplazada" -gt 0 ]; then 
    f_message $S_BACKUP" 1B. Restauramos backup de $C_PURPLE /etc/network/interfaces"$C_DEFAULT
    cp /etc/network/interfaces.bk /etc/network/interfaces
  fi

  f_message $S_CHECK" 2. Mostramos las interfaces de red  $C_PURPLE ip add "$C_DEFAULT

  ip add

  echo -e "=========="
  f_message $S_QUESTION" Por favor indicamos cual es el nombre de interfaz$C_PURPLE que conecta a internet$C_DEFAULT (Ejemplo enp1s0) \n"$C_DEFAULT
  read red_internet # TODO - habilitar en prod
  f_message $S_QUESTION" Por favor indicamos cual es el nombre de interfaz$C_PURPLE que no tiene IP$C_DEFAULT  (esa sera usada para red privada. Ejemplo enp7s0) \n"$C_DEFAULT
  read red_privada # TODO - habilitar en prod
  f_message $S_CHECK" 3. Mostramos las interfaces de red modificadas $C_PURPLE cat /etc/network/interfaces \n"$C_DEFAULT
  echo -e "=========="

  # Modificamos la interfaz
  echo "
#........................
#
# INFERFAZ a RED RESTRINGIDA
#........................
auto $red_privada
iface $red_privada inet static
	address 10.0.0.1
	netmask 255.255.255.0
  " >> /etc/network/interfaces
  cat /etc/network/interfaces

  f_message $S_BACKUP" 4. Reiniciamos Red"$C_DEFAULT

  service networking restart

  f_message $S_CHECK" 5. Mostramos las interfaces de red  $C_PURPLE ip add "$C_DEFAULT

  ip add

  echo "
  red_internet='$red_internet'
  red_privada='$red_privada'
  " > $MY_PATH/tools_regulador/session
}

f_instalar(){  
  echo -e $C_CYAN"🚀 Iniciamos la instalación!"$C_DEFAULT
  f_message $C_RED"🔑 Es posible que se requiera la contraseña para algunas instalaciones"$C_DEFAULT
  # echo -e "1. Verificamos $C_PURPLE cat /etc/resolv.conf"$C_DEFAULT
  # cat /etc/resolv.conf # esto era para los otros equipos linux y deberian de estar a 8.8.8.8

  f_message $S_BACKUP" 1. Actualizamos los Repositorios (Tomate un café (☕️) puede tardar tiempo dependiendo de la velocida de tu internet)"$C_DEFAULT

  apt-get update

  f_intalar_squid # mandamos a instalar squid
  f_instalar_e2guardian # mandamos a instalar e2guardias

      
  if [ ! -f /etc/sysctl.conf.bk ]; then
    f_message $S_BACKUP" 14A. Sacamos backup de $C_PURPLE /etc/sysctl.conf"$C_DEFAULT
    cp /etc/sysctl.conf  /etc/sysctl.conf.bk
  fi

  f_message $S_CHECK" 15. Cambiamos BIT de Forward y verificamos con $C_PURPLE cat /etc/sysctl.conf | grep ipv4.ip_for"$C_DEFAULT
  # reemplazamos con sed la palabra de la linea especifica del archivo y descomentamos
  sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/g' /etc/sysctl.conf 
  cat /etc/sysctl.conf | grep ipv4.ip_for
  # Se activa el cambio al archivo sysctl.conf
  sysctl -p /etc/sysctl.conf
  f_message $S_CHECK" 16. Compartimos internet con Iptables MASQUERADE y FORWARD"$C_DEFAULT
  # limpiamos reglas
  iptables -t nat -F
  iptables -F
  # agregamos regla de redireccion FORFORWARD a la interfaz que conecta con LAN
  iptables -A FORWARD -i $red_privada -j ACCEPT
  iptables -A FORWARD -o $red_privada -j ACCEPT
  # agregamos masquerade a interfaz que conecta a internet
  iptables -t nat -A POSTROUTING -o $red_internet -j MASQUERADE
  
  # Se pone proxy transparente solo con squid
  # iptables -t nat -I PREROUTING -i $red_privada -p tcp --dport 80 -j REDIRECT --to-port 3129

  # Relizar las redirecciones del puerto 80 y 443 al 8080 y 8443 respectivamente utilizando iptables (para e2guardian con SSL)
  # descomentar las siguientes lineas para correr sin proxy

  iptables -t nat -I PREROUTING -i $red_privada -p tcp --dport 80 -j REDIRECT --to-port 8080
  iptables -t nat -I PREROUTING -i $red_privada -p tcp --dport 443 -j REDIRECT --to-port 8443

  # Mostramos configuracion de iptables
  iptables -L -t nat
  iptables -L

  f_reinicia
}
main() {
  if [ $# -lt 1 ]; then
    usage
    exit 1
  else
    
    arr1=(${1//:/ })
    case ${arr1[0]} in
      red) f_red ;;
      instalar) f_instalar ;;
      certificado) f_set_certificados ;;
      reinicia) f_reinicia ;;
      
      *|-h|--help|--ayuda)
          usage # Default to usage
      ;;
    esac
  fi
}

main "$@"



# usage1() {
#   [ "$*" ] && echo "$0: $*"
#   sed -n '/^##/,/^$/s/^## \{0,1\}//p' "$0"
#   exit 2
# } 2>/dev/null