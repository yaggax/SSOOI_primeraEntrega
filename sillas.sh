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
        echo    '“Juegodelassillas”.Introduzcaunaopción>>'
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

        if ! test -f "$LOG"; then
        echo "FECHA|HORA|ANA|JUAN|PABLO|LUIS|CARMEN|ELENA|DORI|BLAS|ZOE|FRAN|TIEMPO|JUGADORES|GANADOR" >"$LOG"
        fi

        for nombre in "${NOMBRES[@]}"; do
        pos="-"
                for ((i = 0; i < ${#ELIMINADOS[@]}; i++))
                do
                        if test  "$nombre" = "${ELIMINADOS[$i]}" 
                        then
                                pos=$((i + 1))  
                                break
                        fi
                done
                RESULT+="$pos|"
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
                SILLAS_D=(${SILLAS_D[*]})   
                NOMBRES2=(${NOMBRES2[*]})
                k=$((k+1))

        done
             
        echo "Asignaciones de sillas:"
        for((i=0; i<${#asignacion[*]}; i++))
        do
                echo
                echo "Silla $((i+1))"
                echo "   ______________"
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
                echo
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
                        echo ♩♭♩♫♬♪♬♫♫♭♭♭♬♩♭
                        read -p "Presionar enter para detener la música."
                        asignacion_sillas
                        
                
                        elif test "$TIEMPO" = "v"
                        then
                                echo Velocidad maxima sin musica
                                asignacion_sillas
                        else
                                echo Tiempo de espera: $TIEMPO
                                echo ♩♭♩♫♬♪♬♫♫♭♭♭♬♩♭
                                sleep $TIEMPO

                                asignacion_sillas
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

ensenarEstadisticas(){
        TOTALTIEMPO=0
        TOTPARTIDAS=0
        MIN_TIEMPO=9999999
        MAX_TIEMPO=0      
        MASCORTA=()
        MASLARGA=()  
        PORCENTAJES=()
        TEMPORAL=0
        declare -A GANADAS FINALISTAS
        JESTAT=()
        ULTIMOS=()
        JUGADAS=()

        for nombre in "${NOMBRES[*]}"; do
                GANADAS[$nombre]=0
                FINALISTAS[$nombre]=0
        done



        #HACER COMENTARIO IFS
        while IFS="|" read -r FECHA HORA ANA JUAN PABLO LUIS CARMEN ELENA DORI BLAS ZOE FRAN TIEMPO_TOTAL JUGADORES GANADOR
        do
    # Saltar la cabecera
        if [ "$FECHA" != "FECHA" ]; then
                # Acumular tiempo total
                TOTALTIEMPO=$((TOTALTIEMPO + TIEMPO_TOTAL))
                TOTPARTIDAS=$((TOTPARTIDAS + 1))
                
                # Guardar el tiempo total en formato con barras
                #echo "|$FECHA|$HORA|$ANA|$JUAN|$PABLO|$LUIS|$CARMEN|$ELENA|$DORI|$BLAS|$ZOE|$FRAN|$TIEMPO_TOTAL|$JUGADORES|$GANADOR|"
                JESTAT=("$ANA" "$JUAN" "$PABLO" "$LUIS" "$CARMEN" "$ELENA" "$DORI" "$BLAS" "$ZOE" "$FRAN")
                for((i=2;i<=10;i++))
                do
                        if test $JUGADORES -eq $i
                        then
                                PORCENTAJES[$i]=$((PORCENTAJES[$i] + 1))
                        else
                                PORCENTAJES[$i]=$((PORCENTAJES[$i] + 0))
                        fi
                done

                
                for((i=0;i<${#JESTAT[*]};i++))
                do      
                        case "${JESTAT[$i]}" in 
                                1)
                                        GANADAS[${NOMBRES[$i]}]=$((GANADAS[${NOMBRES[$i]}] + 1))
                                        ;;
                                2)
                                        FINALISTAS[${NOMBRES[$i]}]=$((FINALISTAS[${NOMBRES[$i]}] + 1))
                                        ;;
                                3)
                                        ULTIMOS[${NOMBRES[$i]}]=$((ULTIMOS[${NOMBRES[$i]}] + 1))
                                        ;;
                                "-")
                                # El jugador no participó, no se hace nada
                                continue
                                ;;
                        esac
                done


                # Actualizar el tiempo mínimo y máximo
                if test $TIEMPO_TOTAL -lt $MIN_TIEMPO 
                then
                        MIN_TIEMPO=$TIEMPO_TOTAL
                        MASCORTA="|$FECHA|$HORA|$ANA|$JUAN|$PABLO|$LUIS|$CARMEN|$ELENA|$DORI|$BLAS|$ZOE|$FRAN|$TIEMPO_TOTAL|$JUGADORES|$GANADOR|"
                fi

                if [ $TIEMPO_TOTAL -gt $MAX_TIEMPO ]; then
                        MAX_TIEMPO=$TIEMPO_TOTAL
                        MASLARGA="|$FECHA|$HORA|$ANA|$JUAN|$PABLO|$LUIS|$CARMEN|$ELENA|$DORI|$BLAS|$ZOE|$FRAN|$TIEMPO_TOTAL|$JUGADORES|$GANADOR|"
                fi

                
        fi
        done < "$LOG"


        echo "Partida más corta: $MASCORTA"
        echo "Partida más larga: $MASLARGA"
        echo "Media de tiempo:   $((TOTALTIEMPO/TOTPARTIDAS))"
        for((i=2;i<=10;i++))
        do
                if test ${PORCENTAJES[$i]} -ne 0 
                then
                        TEMPORAL=$(echo "scale=2; ${PORCENTAJES[$i]} * 100 / $TOTPARTIDAS " | bc)
                        echo "Partida con $i jugadores: ${TEMPORAL}%"
                else
                        echo "Partida con $i jugadores: 0%"

                fi
        done

        echo ${GANADAS[*]}
        echo
        echo
        echo ${FINALISTAS[*]}

        

}



until test "$FLAG" -ne 1
do
        if test "$1" = "-g" 
        then
                echo "SSOOI PRIMERA ENTREGA GRUPAL"
                echo "Integrante 1: Alex Bayle Polo"
                echo "Integrante 2: Yago Houizot López"
                echo
                echo "Campo ADEFINIR en ESTADÍSTICAS:"
                echo " - Este campo se refiere a *[explicación detallada del campo 'ADEFINIR']*."
                exit 0  
        elif test -n "$1" 
        then    
                echo "El programa solo admite como argumento -g"
                echo "Saliendo del programa..."
                exit 0
        fi

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
            ensenarEstadisticas
            ;;
            'S')
            echo Saliendo...
            exit 0
            ;;
    esac                                                                                       
done