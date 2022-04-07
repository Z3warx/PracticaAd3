#!/bin/bash
oldIFS=$IFS
IFS=','
exits=0
#Comprobar si es root
if [ $(id -u) = 0 ]
then
	echo "I am root"
	#Comprobar el numero de parametros que sea correcto(igual a 2)
	if [ $# -eq 2 ]
	then
		#Add usuarios
		if [ $1 == "-a" ]
		then
			cat "$2" | tr -d '\r' | while read name password fullname
			do
			#Distinto de vacio
			if [ ! -z "$name" && ! -z "$password" && ! -z "$fullname" ]
			then
				#Si el usuario existe entonces exists=1 si no exists=0
				grep -q "^$name:" /etc/passwd && exists=1 || exists=0
				if [ $exists -eq 0 ]
				then
					#Falta el k y l
					useradd -c "$fullname" "$name"
					#Con esto cambiamos la contrasena del usuario
					echo "$name:$password" | chpasswd
					#Cambiamos la caducidad de la contrasena a 30 dias
					passwd -x 30 "$name" > /dev/null 2>&1
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
			cat "$2" | tr -d '\r' | while read name password fullname
			do
			#Borramos el usuario y ademas eliminamos el posible mensaje de que el usuario no existe
			userdel "$name" > /dev/null 2>&1
			done
		#Opcion invalida
		else
			echo "Opcion invalida" >2
		fi
	else
		echo "Numero incorrecto de parametros"
	fi
else
	echo "Este script necesita privilegios de administracion"
	exit 1
fi




#Si el usuario ya existe muestra el mensaje exists sino false


useradd -c "nombreCompleto" nombre
chpasswd name:password


#En teoria hace que la contrasena caduca en 30 dias
passwd -x 30 as

useradd usuario
echo "usuario:contrasena" | chpasswd



IFS=$oldIFS
