#!/bin/bash
#
# GNU GPL V2
#
CHEMIN=`pwd`
SOURCE="demo_boulderdash3.asm"
NOM="demo_boulderdash3"
FICHIER_BIN=$CHEMIN"/$NOM.bin"
LISTING="$NOM.lst"
FICHIER_MZF=$CHEMIN"/$NOM.mzf"
# Nom du programme lu par lz sharp MZ sur 16 caracteres
#                        111111
#              0123456789012345
NOM_PROGRAMME="DEMOBOULDERDASH3"

ADRESSE_DEBUT_HAUT=`cat $SOURCE|grep -m 1 "ADRESSE_CODE:"|cut -d "x" -f 2|cut -c1,2`
ADRESSE_DEBUT_BAS=`cat $SOURCE|grep -m 1 "ADRESSE_CODE:"|cut -d "x" -f 2|cut -c3,4`

ADRESSE_EXECUTION_HAUT=`cat $SOURCE|grep -m 1 "ADRESSE_EXEC:"|cut -d "x" -f 2|cut -c1,2`
ADRESSE_EXECUTION_BAS=`cat $SOURCE|grep -m 1 "ADRESSE_EXEC:"|cut -d "x" -f 2|cut -c3,4`

# Compilation
/usr/bin/z80asm -o $FICHIER_BIN $SOURCE --list=$LISTING

# Creation du MZF
if [ -e $FICHIER_BIN ]
 then
  if [ -e $FICHIER_MZF ]
   then
    rm $FICHIER_MZF
  fi
  TAILLE=`ls -l $FICHIER_BIN|cut -d" " -f5`
  HEXA=`printf "%04x\n" $TAILLE`
  TAILLE_HAUT=`echo $HEXA|cut -c1,2`
  TAILLE_BAS=`echo $HEXA|cut -c3,4`

  echo "$FICHIER_MZF  DEBUT=$ADRESSE_DEBUT_HAUT$ADRESSE_DEBUT_BAS TAILLE=$TAILLE_HAUT$TAILLE_BAS EXECUTION=$ADRESSE_EXECUTION_HAUT$ADRESSE_EXECUTION_BAS"

  # Type de fichier
  echo -n -e '\x01' >> $FICHIER_MZF
  # Nom du fichier
  echo -n $NOM_PROGRAMME >> $FICHIER_MZF
  echo -n -e '\x0D' >> $FICHIER_MZF

  # Taille
  echo -n -e "\x$TAILLE_BAS\x$TAILLE_HAUT" >> $FICHIER_MZF
  # Adresse Debut
  echo -n -e "\x$ADRESSE_DEBUT_BAS\x$ADRESSE_DEBUT_HAUT" >> $FICHIER_MZF
  # Adresse Execution
  echo -n -e "\x$ADRESSE_EXECUTION_BAS\x$ADRESSE_EXECUTION_HAUT" >> $FICHIER_MZF
  # Commentaires
  dd bs=104 count=1 if=/dev/zero of=_entete_84_octets.bin status=none
  cat _entete_84_octets.bin >> $FICHIER_MZF
  rm _entete_84_octets.bin
  # Programme
  cat $FICHIER_BIN >> $FICHIER_MZF
 else
  echo "ERREUR : Fichier binaire n'existe pas !"
fi

