#!/bin/sh
#
# Envío de lista de IPs de JmeterSlaves a la ruta donde se encuentran los archivos de prueba
# y agrega esa lista a la configuración de jmeter para pruebas desde equipos remotos.

# ===================================================================
## Variables
# ===================================================================

#filename="20201-Paq_9096"
filename="20201-F1_191998"
#filename="archivo_inscribepaquete"
#filename="20201-Paq_Odonto-926"

#masterpath="/root/scripts/archivosParaPruebas/paq/20201-Paq_9096/" #NOTA: dejar el '/' al final del path
masterpath="/root/scripts/archivosParaPruebas/f1/20201-F1_191998/" #NOTA: dejar el '/' al final del path
#masterpath="/root/scripts/archivosParaPruebas/sql/"
#masterpath="/root/scripts/archivosParaPruebas/paq/20201-Paq_Odonto-926/"

listaServers="awsservers"


listaOriginalServers="listaclientes.reg"
jmeterProperties="/root/jmeter/bin/jmeter.properties"

patronProperties="remote_hosts=172.31"

#====================================================================
## MAIN
#====================================================================

echo "Copiando lista de JmeterSlaves a ruta:"
cp -f $listaOriginalServers $masterpath$listaServers
echo "Listo!"
echo ""

echo "Eliminando archivos de reparto de prueba anterior:"
rm -f $masterpath$filename-*
echo "Listo!"
echo ""


# Existe el archivo con la lista de servers
if [ -e "$masterpath$listaServers" ]
then
	## Imprime $Masterpath
	echo "Masterpath= $masterpath"
	echo "Filename= $filename"
	echo ""

	## Se obtiene la lista de IPs y se le da formato para agregarlo a jmeter.properties
	echo "Dando formato a lista de IPs para JMEter:"
	nuevasIPs="remote_hosts=$(echo $(cat $masterpath$listaServers ) | awk -v OFS="," '$1=$1')"
	echo "Listo!"
	echo ""

	## Remplaza la línea que corresponda al patrón por 
	echo "Reemplazando configuración de JmeterSlaves en jmeter.properties:"
	sed -i "s/.*$patronProperties.*/$nuevasIPs/g" $jmeterProperties
	echo "Listo!"
	echo ""

	## Muestra como queda el cambio en texto
	echo "Visualizando el cambio en el archivo $jmeterProperties:"
	cambio=$(grep $patronProperties $jmeterProperties)
	echo $cambio
	echo ""

	## Se realiza la división del archivo registros totales para uso de pruebas

	echo "Dividiendo los registros totales para uso de pruebas en archivos:"
	cd $masterpath
	echo ""

	awsServers=($(cat $listaServers)) # lista de servidores (ip por renglón en archivo).
	totalLineas=$(cat $filename |wc -l )
	cantidadArchivos=${#awsServers[@]}

	lineasPorArchivo=$((totalLineas/cantidadArchivos))
	resultadoModulo=$((totalLineas%cantidadArchivos))

	if [ $resultadoModulo -eq 0 ]
	then
		split -a 3 -d -l $lineasPorArchivo $filename $filename-
		echo "Se generan $cantidadArchivos archivos con $lineasPorArchivo líneas de registros para la prueba."
		echo "Todos los archivos contienen la misma cantidad de registros."
	else
		split -a 3 -d -l $((lineasPorArchivo+1)) $filename $filename-
		echo "Se generan $cantidadArchivos archivos en total con los $totalLineas registros para la prueba."
		echo "$((cantidadArchivos-1)) contienen $lineasPorArchivo registro y el último archivo contiene $resultadoModulo."
	fi
	echo ""	
	echo "Listo!"
	echo ""

else
	echo "ERROR: No se encuentra el archivo \"$listaServers\" en la ruta \"$masterpath\"."
fi
