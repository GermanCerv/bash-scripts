#!/bin/sh

## IMPORTANTE: Los Path donde se encuentran los archivos para pruebas de Master y Slaves no debe contener espacios
# No incluir la diagonal "/" al final de $path

#====================================================================
## Info: MASTER - Modificar solo $masterpath y $filename
#====================================================================

## Aqui se encontrarán los archivos que enviaremos a los Slaves

#masterpath="/root/scripts/archivosParaPruebas/paq/20201-Paq_9096/"
masterpath="/root/scripts/archivosParaPruebas/f1/20201-F1_191998/"
#masterpath="/root/scripts/archivosParaPruebas/sql/"
#masterpath="/root/scripts/archivosParaPruebas/paq/20201-Paq_Odonto-926/"

## Nombre del grupo de matrículas en Master, mismo que será configurado en el script de pruebas. Ejemplo: "20201-Paq_55766", los archivos para los SLAVES deberían ser así "20201-Paq_55766-##"

#filename="20201-Paq_9096"
filename="20201-F1_191998"
#filename="archivo_inscribepaquete"
#filename="20201-Paq_Odonto-926"


keyfile="/root/scripts/mikey_oct2019.pem" # llave para acceso a instancias de AWS en Master.
listaServers="awsservers" # Lista de Slaves en Master


#====================================================================
## Info: SLAVES - No modificar
#====================================================================

username="root" ##Usuario fijo para acceder a instancias de AWS
slavepath="/$username/jmeter/bin/" # Path donde los Slaves tendrán los archivos con info para la ejecución de los scripts, estos deben estar en este path para no tener problemas en la ejecución del script


#====================================================================
## MAIN - No modificar
#====================================================================

cd $masterpath

# Existe el archivo con la lista de servers
#if [ -e "$listaServers" ]
if [ -e "$masterpath$listaServers" ]
then

	awsServers=($(cat $listaServers)) # lista de servidores (ip por renglón en archivo).
	files=($(ls . |grep -i ${filename}-)) # arreglo de nombres de archivos seguido de un guión medio y ID para  enviar. Ejemplo: "20201-Paq_55766-00"

	# Existen archivos que contengan el nombre indicado?
	if [ ${#files[@]} -eq 0 ]
	then
		echo "ERROR: No se encuentran archivos que contengan \"$filename\" en el nombre dentro del path indicado: $masterpath."

	else
		## Corresponde la cantidad de archivos con la cantidad de servidores en la lista de awsservers?
		if [ ${#files[@]} -eq ${#awsServers[@]} ]
		then
			i=0 # index

			echo "========================================================================" | tee -a logs.txt
			echo "Iniciando envío de archivos a JMeter slaves"  | tee -a logs.txt
			echo "Path de master = $masterpath" | tee -a logs.txt
			echo "Path de slave = $slavepath" | tee -a logs.txt
			echo "Archivo = $filename-##" | tee -a logs.txt
			date | tee -a logs.txt
			echo "========================================================================" | tee -a logs.txt

			for file in "${files[@]}"
			do
#				scp -i $keyfile -o StrictHostKeyChecking=no $file $username@${awsServers[$i]}:$slavepath$filename | tee -a logs.txt
				scp -i $keyfile -o StrictHostKeyChecking=no -o LogLevel=ERROR $file $username@${awsServers[$i]}:$slavepath$filename | tee -a logs.txt
				echo "Archivo: $file -> Server: ${awsServers[$i]}" | tee -a logs.txt
				echo "keyfile= $keyfile ; username = $username ; slavepath = $slavepath ; filename = $filename"
				echo "--------------------------------------------------------" | tee -a logs.txt

				i=$((i+1))
			done

			echo "========================================================================" | tee -a logs.txt
			echo "Terminó de envío de archivos"  | tee -a logs.txt
			echo "========================================================================" | tee -a logs.txt

		# Cantidad de archivos y servidores no concuerda en números
		else
			echo "ERROR: El numero de archivos no concuerda con la cantidad de servers en la lista."
			echo "Files: ${#files[@]}, AWSservers: ${#awsServers[@]}"
			echo "Ruta: \"$masterpath\""
		fi

	fi

# No existe el archivo con la lista de servers
else
	echo "ERROR: No se encuentra el archivo \"$listaServers\" con la lista de servidores en la ruta \"$masterpath\"."
fi
