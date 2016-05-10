#!/bin/bash


# Skript durchsucht einen Quellpfad nach DATA VITAL GDT Einstellungs-
# dateien. Alle Treffer werden in einen Zielpfad kopiert.
#
# Ausserdem werden eventuelle GDT Skripte gesammelt, sofern diese in den
# Einstellungen die Endung '.sh' tragen und in der Quelle gefunden werden.
#
# Skript als root starten!
#
# Speedpoint (FW), Stand: April 2016; Version 2


#######################################################

# Bitte anpassen:

# Pfad mit den Quelldaten:
QUELLE="/install/migration/home"

# Pfad fuer extrahierte Dateien:
ZIEL="/home/david/Desktop/OLD_GDT"

#######################################################























# Duerfen wir das alles?
if [ "$(id -u)" != "0" ]; then
	echo ""
	echo " ## ABBRUCH, Ausfuehrung nur durch root!"
	echo ""
	exit 1
fi


echo ""
echo ""
echo "----------------------------"
echo "Suche nach GDT Einstellungen"
echo "----------------------------"
echo ""
echo ""
echo "Zum Beginnen bitte die ENTER Taste druecken (STRG-C fuer Abbruch)..."
echo ""
read dummy


# Anzahl Treffer ermitteln:
if [ -d $QUELLE ]; then
	HIT=`find $QUELLE -type f -name gdtrc | wc -l`
	echo "Suche in $QUELLE nach GDT Einstellungen... "
else
	echo "## ABBRUCH: Quellverzeichnis $QUELLE nicht gefunden."
	echo ""
	echo ""
	exit 1
fi


# Daten extrahieren, falls vorhanden:
if [ "$HIT" -gt 0 ]; then
    mkdir -m 777 $ZIEL 2>/dev/null
    #
    for i in `ls $QUELLE`; do
        echo "    GDT Einstellungen gefunden fuer User '$i'."
        find $QUELLE/$i/.qt -type f -name gdtrc -print0  2>/dev/null | xargs -0 cat >$ZIEL/gdtrc_$i
    done
    #
    echo "    - - - - - - - - - - - - - - - - - - - - - - - -"
    #
    # GDT Skripte in den gefundenen Einstellungen suchen:
    for k in `fgrep -e '.sh' $ZIEL/* | awk -F "=" '{print $2}' | sed -e 's/^\/home\///'`; do
	FEHLER=0
	    cp $QUELLE/$k $ZIEL >/dev/null 2>&1 || FEHLER=1
        #
	if [  "$FEHLER" = 1 ]; then 
	    echo " ## Skript '$QUELLE/$k' wurde nicht gefunden." 
	fi
        #
    done
    #
    chmod 775 $ZIEL/*
    chown david:users $ZIEL/*
    echo ""
    echo "Suche abgeschlossen. Kopierte Dateien liegen in $ZIEL."
    echo ""
    echo "--------------------------------------------------------------"
    echo "Bitte die Vollstaendigkeit der GDT Skripte aller User pruefen!"
    echo "--------------------------------------------------------------"
else
    echo "## Keine GDT Einstellungen zur Migration gefunden."
fi


echo ""
echo "Ende."
echo ""
echo ""


exit 0
