#!/bin/bash

JUGADORES=0
NOJUEGAN=0
TIEMPO=-1
FLAG=1
NOMBRES=("ANA" "JUAN" "PABLO" "LUIS" "CARMEN" "ELENA" "DORI" "BLAS" "ZOE" "FRAN")


mostrarmenu(){
        echo --------------------------------------
        echo           JUEGO DE LAS SILLAS
        echo --------------------------------------
        echo                  MENU
        echo --------------------------------------
        echo    'C) CONFIGURACION'
        echo    'J) JUGAR'
        echo    'E) ESTADISTICAS' 
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
                #el soruce nos permite ejecutar el programa, en este caso h$        
        else
                echo El archivo de configuración config.cfg no existe. Abortando
                exit 1                                                      
        fi
}

configuracion(){

        echo  CONFIGURACION  
        echo  -------------
        JUGADORES=0
        TIEMPO=-1
        until test "$JUGADORES" -le 10 -a "$JUGADORES" -ge 2
        do                                                                                 
                echo Numeros de jugadores entre 2 y 10
                read JUGADORES
        done                                                                                                                                            
        # COMPROBACION de que si es un numero sino es una letra                     
        until [[ ( "$TIEMPO" =~ ^[0-9]+$ && "$TIEMPO" -ge 0 && "$TIEMPO" -le 10 ) || "$TIEMPO" == "v" || "$TIEMPO" == "i" ]]
        do
                echo "Tiempo de juego: 0-10, 'v' para velocidad máxima sin música, 'i' para pararlo de manera interactiva."
                read TIEMPO
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
        RESULT=""
        GANADOR="$NOMBRES2"
        FECHA=$(date +%d/%m/%y)
        HORA=$(date +%H:%M)
        TIEMPOIN=$((10#${TIEMPOIN:0:2} * 3600 + 10#${TIEMPOIN:2:2} * 60 + 10#${TIEMPOIN:4:2}))
        TIEMPOFIN=$((10#${TIEMPOFIN:0:2} * 3600 + 10#${TIEMPOFIN:2:2} * 60 + 10#${TIEMPOFIN:4:2}))
        TOTALTIEMPO=$((TIEMPOFIN - TIEMPOIN))
        RESULT="$FECHA|$HORA|"
        while test $k -lt ${#ELIMINADOS[*]}     
        do
                echo ${ELIMINADOS[k]}
                RESULT="${RESULT}${ELIMINADOS[k]}|"
                k=$((k + 1))
        done     
        RESULT="${RESULT}$TOTALTIEMPO segundos|$JUGADORES|$GANADOR"
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

asignacion_sillas(){
        SILLAS_D=()
        asignacion=()
        
        k=0
        for ((i=1; i<=SILLAS; i++)) 
        do
                SILLAS_D+=($i)
        done
        while test ${#NOMBRES2[*]} -gt 1
        do
                INDICE=$(($RANDOM % ${#SILLAS_D[*]}))
                INDICE2=$(($RANDOM % ${#NOMBRES2[*]}))
                asignacion[$k]=${NOMBRES2[$INDICE2]}

                unset SILLAS_D[$INDICE]
                unset NOMBRES2[$INDICE2]
                echo ${asignacion[$k]}
                SILLAS_D=(${SILLAS_D[*]})   
                NOMBRES2=(${NOMBRES2[*]})
                k=$((k+1))

        done
             
        # Imprimir las asignaciones de sillas
        echo "Asignaciones de sillas:"
        for((i=0; i<${#asignacion[*]}; i++))
        do
                echo "Silla $((i+1))"
                echo "   | __  __  __ |"
                echo "   ||  ||  ||  ||"
                echo "   ||  ||  ||  ||"
                echo "   ||  ||  ||  ||"
                echo "  /             /"
                echo " /     ${asignacion[$i]} "
                echo "/_____________/  |"
                echo "|  |          |  |"
                echo "|  |          |  |"
                echo "|  |          |  |"
                echo "|             |"
        done

        echo Eliminado ${NOMBRES2[0]}
        ELIMINADOS[${#asignacion[*]}]=${NOMBRES2[0]}

        NOMBRES2=()
        NOMBRES2=${asignacion[*]}
        SILLAS=$((SILLAS-1))

}

jugar(){
        cargar_configuracion
        SILLAS=$((JUGADORES-1))
        cargarNombresP
        TIEMPOIN=$(date +%H%M%S)
        SILLAS_D=()
        ELIMINADOS=()
               
        
        echo ${SILLAS_D[*]}
        echo ${NOMBRES2[*]}
        while test $SILLAS -gt 0
        do                                                                                                                                                                                                        
                echo Numero jugadores: ${#NOMBRES2[*]}
                echo Numero de sillas: $SILLAS


                if test "$TIEMPO" = "i"
                then
                        asignacion_sillas
                        read -p "Presionar enter para detener el juego."
                        
                
                        elif test "$TIEMPO" = "v"
                        then
                                echo Velocidad maxima sin musica
                                asignacion_sillas
                        else
                                echo Tiempo de espera: $TIEMPO
                                asignacion_sillas
                                sleep $TIEMPO
                        fi
                
                NOMBRES2=(${NOMBRES2[*]})
                read -p "Pulse alguna tecla para seguir con la partida."                                                                                                                
        done
        echo ================================
        echo "${NOMBRES2} ha sido el ganador"
        echo ================================
        ELIMINADOS[0]=$NOMBRES2
        TIEMPOFIN=$(date +%H%M%S)
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