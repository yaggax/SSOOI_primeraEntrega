#!/bin/bash

JUGADORES=0
NOJUEGAN=0
TIEMPO=-1
FLAG=1
NOMBRES=("ANA" "JUAN" "PABLO" "LUIS" "CARMEN" "ELENA" "DORI" "BLAS" "ZOE" "FRAN")

#linea 10
mostrarmenu(){
        echo --------------------------------------
        echo           JUEGO DE LAS SILLAS
        echo --------------------------------------
        echo                  MENU
        echo --------------------------------------
        echo    'C) CONFIGURACION'
        echo    'J) JUGAR'
        echo    'E) ESTADISTICAS' #linea 20
        echo    'S) SALIR'
        echo    'Introduzca una opción>>'
        read OPCION
        echo Pulse una tecla para continuar
        read
        echo --------------------------------------

}

cargar_configuracion() {
        if test -f "config.cfg"
        then
                source config.cfg
                #el soruce nos permite ejecutar el programa, en este caso h$        else
                echo El archivo de configuración config.cfg no existe. Abortando
                exit 1                                                      
        fi
}
#linea 40
configuracion(){

        echo  CONFIGURACION  
        echo  -------------
        JUGADORES=0
        TIEMPO=-1
        until test "$JUGADORES" -le 10 -a "$JUGADORES" -ge 2
        do                                                                 $                echo Numeros de jugadores entre 2 y 10
                read JUGADORES
        done                                                                                                                                            
        # COMPROBACION de que si es un numero sino es una letra                     
        until [[ ( "$TIEMPO" =~ ^[0-9]+$ && "$TIEMPO" -ge 0 && "$TIEMPO" -le 10 ) || "$TIEMPO" == "v" || "$TIEMPO" == "i"]]
        do
                echo Tiempo de juego de 0-10,v velocidad maxima sin musica,i para pararlo de manera interactiva.
                read TIEMPO
        #linea 60
        done

        echo -n "Ruta del archivo de log: "
        read LOG
        LOG=$LOG
        echo "JUGADORES=$JUGADORES" >config.cfg
        echo "TIEMPO=$TIEMPO">>config.cfg
        echo "LOG=$LOG">>config.cfg
}

registrarPartida(){          
        k=0
        GANADOR="$NOMBRES2"
        FECHA=$(date +%d/%m/%y)
        HORA=$(date +%H:%M)
        echo ${ELIMINADOS[*]}

        RESULT="$FECHA|$HORA|"
        while test $k -lt ${#ELIMINADOS[*]}     
        do
                RESULT="${RESULT}${ELIMINADOS[k]}|"
                k=$((k + 1))
        done     
        RESULT="${RESULT}$TOTALTIEMPO|$JUGADORES|$GANADOR"
        if test -f "$LOG"
        then
            echo "$RESULT">>fichero.log
        else    
            echo No existe el archivo fichero.log
            exit 1
        fi


}

cargarNombresP(){
         i=0
        while test $i -lt $JUGADORES                                                                     
        do
                INDICE=$(($RANDOM%10))
                NOMBRES2[$i]=${NOMBRES[$INDICE]}

                if test $i -eq 0
                then
                        i=$((i+1))

                else
                        j=0
                        repetido=false
                        while test $j -lt $i
                        do
                                if test "${NOMBRES2[$i]}" = "${NOMBRES2[$j]}" 
                                then
                                        repetido=true
                                break
                                fi
                        j=$((j+1))
                        done

                if ! $repetido
                        then
                        i=$((i+1))
                fi
         fi
         done
}

jugar(){
        cargar_configuracion
        SILLAS=$((JUGADORES-1))
        cargarNombresP

        while test ${#NOMBRES2[*]} -gt 1
        do                                                                                                                                                                                                        
                echo Numero jugadores: ${#NOMBRES2[*]}
                echo Numero de sillas: $SILLAS

                if test "$TIEMPO" = "v"   
                then
                        echo Velocidad maxima sin musica
                        sleep 1
                elif test "$TIEMPO" = "i"
                then
                        read -p "Presionar enter para detener el juego."
                else
                        echo Tiempo de espera: $TIEMPO
                        sleep $TIEMPO
                fi

                INDICE=$(($RANDOM%${#NOMBRES2[*]}))
                echo "${NOMBRES2[INDICE]} ha sido eliminado."

                #Vamos a crear otro array que contenga en orden los jugadores eliminados
                ELIMINADOS[${#NOMBRES2[*]}]=${NOMBRES2[INDICE]}
                unset NOMBRES2[INDICE]

                NOMBRES2=(${NOMBRES2[*]})

                SILLAS=$((SILLAS-1))
                read -p "Pulse alguna tecla para seguir con la partida."                                                                                                        
        done
        echo ${NOMBRES2} ha sido el ganador
        ELIMINADOS=$NOMBRES2
        registrarPartida
}                                                                                                                                                                                                 
until test "$FLAG" -ne 1
do

    # MENU----------------------------------------------
    mostrarmenu                                                                                      

    case $OPCION in
            'C' )
            configuracion
            ;;

                                                                                                            
            'J' )
            jugar
            ;;


            'E')
            echo Esstadisticas
            ;;
            'S')
            echo Saliendo...
            exit 0
            ;;
    esac                                                                                       
done