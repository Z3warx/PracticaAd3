#!/bin/bash
#818058, Arcega, Hector, T, 3, A
#821038, Alonso, Simon, T, 3, A

oldIFS=$IFS
IFS=','
exits=0

#Comprobar si es root
if [ $(id -u) = 0 ]
then
	#Comprobar el numero de parametros que sea correcto(igual a 2)
	if [ $# -eq 2 ]
	then
		#Add usuarios
		if [ $1 == "-a" ]
		then
			cat "$2" | tr -d '\r' | while read name password fullname
			do
			#Distinto de vacio todos los campos
			if [[ ! -z "$name" && ! -z "$password" && ! -z "$fullname" ]]
			then
				#Si el usuario existe entonces exists=1 si no exists=0
				grep -q "^$name:" /etc/passwd && exists=1 || exists=0
				if [ $exists -eq 0 ]
				then	
					useradd -c "$fullname" -m -k /etc/skel -U -K UID_MIN=1815 -d "/home/$name" "$name"
					#Con esto cambiamos la contrasena del usuario
					echo "$name:$password" | chpasswd
					#Cambiamos la caducidad de la contrasena a 30 dias
					passwd -x 30 "$name" > /dev/null 2>&1
					#Especificamos el grupo al que pertenece el usuario
					usermod -G "$name" "$name"
					echo "$fullname ha sido creado"
				else
					echo "El usuario $name ya existe"
				fi
			else
				echo "Campo invalido"
				exit 1
			fi
			done
			
		#Borrar usuarios
		elif [ $1 == "-s" ]
		then
			mkdir /extra > /dev/null 2>&1
			mkdir /extra/backup > /dev/null 2>&1
			cat "$2" | tr -d '\r' | while read name password fullname
			do
			#Creamos el archivo .tar
			tar -cf $name.tar /home/$name > /dev/null 2>&1
			#movemos el archivo .tar al directorio /extra/backup
			mv $name.tar /extra/backup
			#Comprobamos que el backup se ha realizado correctamente
			if [ $? -eq 0 ]
			then
			#Borramos el usuario y ademas eliminamos el posible mensaje de que el usuario no existe
				userdel -r "$name" > /dev/null 2>&1
			fi
			done
			
		#Opcion invalida
		else
			echo "Opcion invalida"
		fi
	else
		echo "Numero incorrecto de parametros"
	fi
else
	echo "Este script necesita privilegios de administracion"
	exit 1
fi

IFS=$oldIFS
