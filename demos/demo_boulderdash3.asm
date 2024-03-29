;
;    DEMO BOULDER DASH III - 07/08/2019
;
;    Copyright (c) 2019 by PACMAN
;
;    This program is free software; you can redistribute it and/or modify
;    it under the terms of the GNU General Public License as published by
;    the Free Software Foundation; either version 2 of the License, or
;    (at your option) any later version.
;
;    DEMO GCG is distributed in the hope that it will be useful,
;    but WITHOUT ANY WARRANTY; without even the implied warranty of
;    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;    GNU General Public License for more details.
;
;    You should have received a copy of the GNU General Public License
;    along with DEMO GCG; if not, write to the Free Software
;    Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
;
;
; ==============================================================================
;
; Auteur : PACMAN
; Annee  : 2019
;
; Petite demonstration rapide des possibilites de la carte de
; generation de caractreres graphiques.
;
; Presentation de Boulder Dash 3.
;
; ------------------------------------------------------------------------------
;
; Compilation :
;
;  z80asm -o demo_cgc.bin demo_boulderdash3.asm
; ou
;  z80asm -o demo_cgc.bin demo_boulderdash3.asm --list=demo_boulderdash3.lst
;
; ==============================================================================
;
GCG700EXT_DONNEE:	EQU 0xE010
GCG700EXT_ADRESSE1:	EQU GCG700EXT_DONNEE+1
GCG700EXT_ADRESSE2:	EQU GCG700EXT_DONNEE+2
GCG700EXT_CONTROLE:	EQU GCG700EXT_DONNEE+3

GCG700_INIT_CONTROLE:		EQU 0x80
GCG700_INIT_MODE_TEXTE:		EQU 0x00
GCG700_INIT_MODE_GRAPHIQUE:	EQU 0x08

MONIT:				EQU 0x0000
BRKEY:				EQU 0x001E
ST0:				EQU 0x00AD

ECRAN_CARACTERE:	EQU 0xD000
ECRAN_COULEUR:		EQU 0xD800

; ------------------------------------------------------------------------------
; Adresse d'implementation du code
; ------------------------------------------------------------------------------
;
ADRESSE_CODE:		EQU 0x125C
ADRESSE_EXEC:		EQU 0x125C

; ------------------------------------------------------------------------------
; Programme principal
; ------------------------------------------------------------------------------
;
ORG ADRESSE_CODE

; ------------------------------------------------------------------------------
DEMO_BD_BOOT:
  ;   -----------------------
  ; ---   INITIALISATIONS   ---
  ;   -----------------------
  ;
  CALL	GCG700_INIT
  CALL	GCG700_MODE_TEXTE
  
  ; Efface l'ecran et couleur Noir sur Noir
  XOR	A
  CALL	EFFACE_ECRAN_TEXTE

  ; Ecrit les differents motifs dans le GCG
  LD	DE, JEU_00_00
  LD	HL, 0x0000
  LD	BC, 0xEB00
  CALL	GCG700_PROGRAMME_CARACTERES
  
  ; Remplissage ecran de caracteres
  LD	HL, ECRAN_CARACTERE+0x04
  LD	DE, CARACTERES
 BOUCLE_1:  
  LD	BC, 0x2008
 BOUCLE_2:
  LD	A, (DE)
  LD	(HL), A
  INC	HL
  INC	DE
  DJNZ	BOUCLE_2
  ADD	HL, BC
  LD	A, D
  CP	0x16
  JR	NZ, BOUCLE_1
  
  ; Affiche l'ecran
  XOR	A
  CALL	GCG700_MODE_GRAPHIQUE
  
  ; Remplissage ecran des couleurs
  LD	HL, ECRAN_COULEUR+0x04
  LD	DE, COULEURS
 BOUCLE_3:
  LD	BC, 0x2008
 BOUCLE_4:
  LD	A, (DE)
  LD	(HL), A
  INC	HL
  INC	DE
  DJNZ	BOUCLE_4
  ADD	HL, BC
  LD	A, D
  CP	0x19
  JR	NZ, BOUCLE_3
      
  ; Attend SHIFT+BREAK
 BOUCLE_5:
  CALL	BRKEY
  JR	NZ, BOUCLE_5
  
  ; Revient au moniteur
  CALL	GCG700_MODE_TEXTE
  JP	MONIT
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Remplit l'ecran texte + couleur
; ------------------------------------------------------------------------------
EFFACE_ECRAN_TEXTE:
  LD	DE, ECRAN_CARACTERE+0x0001
  LD	HL, ECRAN_CARACTERE
  LD	BC, 0x0FFF
  LD	(HL), A
  LDIR
  RET
; ------------------------------------------------------------------------------


; ==============================================================================
; FONCTIONS SPECIFIQUES GCG-700 Version EXT(ension)
; ------------------------------------------------------------------------------
;
; ------------------------------------------------------------------------------
; Fonction d'initialisation du GCG-700 EXT
; ------------------------------------------------------------------------------
GCG700_INIT:
  PUSH	HL
   LD	HL, GCG700EXT_CONTROLE
   LD	(HL), GCG700_INIT_CONTROLE
  POP	HL
  RET
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Fonction qui envoi B caracteres au GCG-700 EXT
; ------------------------------------------------------------------------------
;
GCG700_PROGRAMME_CARACTERES:
  CALL	GCG700_PROGRAMME_1_CARACTERE
  INC	L
  DJNZ	GCG700_PROGRAMME_CARACTERES
  RET
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Mode Texte
; ------------------------------------------------------------------------------
GCG700_MODE_TEXTE:
  PUSH	HL
   LD	HL, GCG700EXT_ADRESSE2
   LD	(HL), GCG700_INIT_MODE_TEXTE
  POP	HL
  RET
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Mode Graphique du GCG
; ------------------------------------------------------------------------------
;
GCG700_MODE_GRAPHIQUE:
  RRCA
  RRCA
  AND	0xC0
  OR	GCG700_INIT_MODE_GRAPHIQUE
  LD	(GCG700EXT_ADRESSE2), A
  RET
; ------------------------------------------------------------------------------

; ------------------------------------------------------------------------------
; Fonction qui met en place un caractere de 8x8 bits sur une plage de 256 caracteres
; ------------------------------------------------------------------------------
;
GCG700_PROGRAMME_1_CARACTERE:
  PUSH	BC
  PUSH	HL
   LD	B, 0x08
   LD	A, H
   RLA
   RLA
   RLA
   LD	H, A
   ADD	HL, HL
   ADD	HL, HL
   ADD	HL, HL
GCG700_PROGRAMME_1_CARACTERE_BOUCLE:
   LD	A, (DE)
   PUSH	DE
    LD	DE, GCG700EXT_DONNEE
    LD	(DE), A
    INC	DE
    LD	A, L
    LD	(DE), A
    INC	DE
    LD	A, H
    OR	0x10
    LD	(DE), A
    AND	0xEF
    NOP
    NOP
    LD	(DE), A
   POP	DE
   INC	DE
   INC	HL
   DJNZ	GCG700_PROGRAMME_1_CARACTERE_BOUCLE
  POP	HL
  POP	BC
  RET
; ------------------------------------------------------------------------------

; Donnees
CARACTERES:
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0a, 0x0b
 DB 0x0c, 0x0d, 0x0e, 0x0f, 0x10, 0x11, 0x12, 0x13, 0x14, 0x15, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x16, 0x17, 0x14, 0x18, 0x19, 0x1a, 0x1b, 0x1c, 0x1d, 0x1e, 0x1f
 DB 0x20, 0x21, 0x22, 0x23, 0x24, 0x25, 0x26, 0x27, 0x28, 0x29, 0x2a, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x2b, 0x2c, 0x2d, 0x2e, 0x2f, 0x30, 0x31, 0x32, 0x33, 0x34, 0x35
 DB 0x20, 0x36, 0x37, 0x38, 0x39, 0x3a, 0x3b, 0x3c, 0x3d, 0x3e, 0x3f, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x40, 0x41, 0x42, 0x43, 0x44, 0x45, 0x46, 0x47, 0x48, 0x49, 0x4a
 DB 0x4b, 0x4c, 0x4d, 0x4e, 0x4f, 0x50, 0x51, 0x52, 0x53, 0x54, 0x55, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x2b, 0x14, 0x14, 0x14, 0x56, 0x57, 0x58, 0x59, 0x5a, 0x5b, 0x5c
 DB 0x5d, 0x5e, 0x5f, 0x60, 0x61, 0x62, 0x63, 0x64, 0x65, 0x66, 0x67, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x68, 0x69, 0x6a, 0x6b, 0x6c, 0x6d, 0x6e, 0x6f, 0x70, 0x71, 0x72
 DB 0x73, 0x74, 0x75, 0x76, 0x77, 0x78, 0x79, 0x7a, 0x7b, 0x7c, 0x7d, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x7e, 0x7f, 0x80, 0x81, 0x82, 0x83, 0x84, 0x85, 0x86, 0x87, 0x88
 DB 0x89, 0x8a, 0x8b, 0x8c, 0x77, 0x8d, 0x8e, 0x8f, 0x90, 0x91, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x92, 0x93, 0x94, 0x95, 0x96, 0x97, 0x98, 0x98, 0x99, 0x9a, 0x14
 DB 0x9b, 0x9c, 0x9d, 0x9e, 0x9f, 0xa0, 0xa1, 0xa2, 0xa3, 0xa4, 0x9f, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa5, 0x2d
 DB 0xa6, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa7, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xa8, 0xa9, 0xaa, 0xab, 0x00, 0xac, 0xad, 0xae
 DB 0xaf, 0xb0, 0xb1, 0xb2, 0xb3, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0xb5, 0xb6, 0xb7, 0xb8, 0xb9, 0xba, 0xbb, 0xbc
 DB 0xbd, 0xbe, 0xbf, 0xc0, 0xb3, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4, 0xb4
 DB 0x00, 0x00, 0x00, 0x00, 0xc1, 0xc2, 0xc3, 0xc4, 0xc5, 0xc6, 0xc7, 0xc8, 0xc9, 0xca, 0xcb, 0xcc
 DB 0xcd, 0xce, 0xcf, 0xd0, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0xc7, 0xc7, 0xc7, 0xc7, 0xd1, 0xd2, 0xd3, 0xd4, 0xc7, 0xd5, 0xd6, 0xc7, 0xd7, 0x00, 0xd8, 0x00
 DB 0xd9, 0xda, 0xdb, 0xdc, 0xdd, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xde, 0xdf, 0xe0, 0xe1, 0xe2, 0xe3, 0xe4, 0xe5
 DB 0xe6, 0xe7, 0xe8, 0xe9, 0xea, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

COULEURS:
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50, 0x50
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x60, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x60, 0x60, 0x60, 0x60, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x60, 0x60, 0x60, 0x20, 0x20, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20
 DB 0x10, 0x10, 0x10, 0x20, 0x20, 0x20, 0x20, 0x20, 0x60, 0x10, 0x10, 0x20, 0x20, 0x20, 0x20, 0x20
 DB 0x20, 0x20, 0x20, 0x20, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x20, 0x10, 0x10, 0x20, 0x20, 0x20, 0x20, 0x10
 DB 0x20, 0x20, 0x20, 0x20, 0x20, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10, 0x10
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00

; ------------------------------------------------------------------------------
;
JEU_00_00:
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Caractere 00
 DB 0x00, 0x03, 0x02, 0x02, 0x02, 0x02, 0x02, 0x02 ; Caractere 01
 DB 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0xFC, 0xFD, 0xFD ; Caractere 02
 DB 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0x00 ; Caractere 03
 DB 0x00, 0xFE, 0x01, 0xFC, 0xFF, 0x3F, 0x9F, 0xEF ; Caractere 04
 DB 0x00, 0x00, 0x80, 0x40, 0x23, 0x9C, 0xD1, 0xEF ; Caractere 05
 DB 0x00, 0x01, 0x1E, 0xE0, 0x0F, 0xFF, 0xFF, 0xFF ; Caractere 06
 DB 0x00, 0xFC, 0x03, 0xF8, 0xFF, 0xFF, 0xFF, 0xFF ; Caractere 07
 DB 0x00, 0x00, 0xC0, 0x38, 0x86, 0xF1, 0xFC, 0xFF ; Caractere 08
 DB 0x00, 0xFF, 0x80, 0xBF, 0xBF, 0xBF, 0x7F, 0x3F ; Caractere 09
 DB 0x00, 0xC1, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41 ; Caractere 0A
 DB 0x00, 0xFF, 0x00, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E ; Caractere 0B
 DB 0x00, 0x80, 0x80, 0x80, 0xFF, 0x81, 0xFD, 0xFD ; Caractere 0C
 DB 0x00, 0x3F, 0x20, 0x2F, 0x2F, 0x2F, 0x2F, 0x2F ; Caractere 0D
 DB 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF ; Caractere 0E
 DB 0x00, 0xFE, 0x01, 0xFC, 0xFF, 0xFF, 0xFF, 0xFF ; Caractere 0F
 DB 0x00, 0x07, 0xC4, 0x35, 0x8D, 0xE5, 0xF3, 0xF9 ; Caractere 10
 DB 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xFC ; Caractere 11
 DB 0x00, 0xFF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00 ; Caractere 12
 DB 0x00, 0xC0, 0x40, 0x40, 0x7F, 0x40, 0x7F, 0x7F ; Caractere 13
 DB 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFF, 0xFF ; Caractere 14
 DB 0x00, 0x00, 0x00, 0x00, 0xF0, 0x0C, 0xE2, 0xF9 ; Caractere 15
 DB 0x02, 0x02, 0x03, 0x00, 0x00, 0x00, 0x00, 0x00 ; Caractere 16
 DB 0xFD, 0x1D, 0xDD, 0x5D, 0x5D, 0x5C, 0x5F, 0x5F ; Caractere 17
 DB 0x2F, 0x2F, 0x2F, 0xEF, 0x9F, 0x3F, 0xFF, 0xFC ; Caractere 18
 DB 0xEF, 0xEF, 0xEF, 0xEF, 0xDF, 0x9F, 0x3F, 0x7F ; Caractere 19
 DB 0xFF, 0xFF, 0xFC, 0xFB, 0xF6, 0xEC, 0xE8, 0xE8 ; Caractere 1A
 DB 0xFF, 0x07, 0xF9, 0x8E, 0x03, 0x01, 0x00, 0x00 ; Caractere 1B
 DB 0xFF, 0xFF, 0xFF, 0xFF, 0x7F, 0xBF, 0xBF, 0xBF ; Caractere 1C
 DB 0x9F, 0xCF, 0xEF, 0xE7, 0xF7, 0xF3, 0xFB, 0xFB ; Caractere 1D
 DB 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41, 0x41 ; Caractere 1E
 DB 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E ; Caractere 1F
 DB 0xFD, 0xFD, 0xFD, 0xFD, 0xFD, 0xFD, 0xFD, 0xFD ; Caractere 20
 DB 0x21, 0x3D, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05 ; Caractere 21
 DB 0xF0, 0xF7, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4 ; Caractere 22
 DB 0x0F, 0xF3, 0x1D, 0x06, 0x03, 0x01, 0x01, 0x00 ; Caractere 23
 DB 0xFD, 0xFC, 0xFE, 0xFE, 0x7E, 0x7E, 0xBE, 0xBE ; Caractere 24
 DB 0xFD, 0xFD, 0xFD, 0xFD, 0xFD, 0xFC, 0xFF, 0xFF ; Caractere 25
 DB 0xFF, 0x01, 0x01, 0x01, 0xF9, 0x09, 0xE9, 0xE9 ; Caractere 26
 DB 0xFF, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E ; Caractere 27
 DB 0xFF, 0x01, 0xFE, 0x81, 0x80, 0x80, 0x80, 0x81 ; Caractere 28
 DB 0xFC, 0xFE, 0x7E, 0x3F, 0xBF, 0x9F, 0xBF, 0x3F ; Caractere 29
 DB 0x80, 0x80, 0x40, 0x40, 0x40, 0x40, 0x40, 0x40 ; Caractere 2A
 DB 0x00, 0x00, 0x00, 0x00, 0x03, 0x02, 0x02, 0x02 ; Caractere 2B
 DB 0x5F, 0x5C, 0x5D, 0x5D, 0xDD, 0x1D, 0xFD, 0xFD ; Caractere 2C
 DB 0xFF, 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00 ; Caractere 2D
 DB 0xFF, 0x3F, 0x9F, 0xEF, 0x2F, 0x2F, 0x2F, 0xEF ; Caractere 2E
 DB 0x3F, 0x9F, 0xDF, 0xEF, 0xEF, 0xEF, 0xEF, 0xEF ; Caractere 2F
 DB 0xE8, 0xEC, 0xF6, 0xFB, 0xFC, 0xFF, 0xFF, 0xFF ; Caractere 30
 DB 0x00, 0x01, 0x03, 0x8E, 0xF9, 0x07, 0xFF, 0xFF ; Caractere 31
 DB 0xBF, 0xBF, 0x7F, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF ; Caractere 32
 DB 0xFB, 0xF3, 0xF7, 0xE7, 0xEF, 0xCF, 0x9F, 0x2F ; Caractere 33
 DB 0x41, 0x41, 0x41, 0x22, 0x9C, 0xC1, 0xFF, 0xFF ; Caractere 34
 DB 0x7E, 0x7E, 0x7E, 0x7E, 0xFE, 0xFE, 0xFE, 0xFC ; Caractere 35
 DB 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05, 0x05 ; Caractere 36
 DB 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF7, 0xF0, 0xFF ; Caractere 37
 DB 0x01, 0x01, 0x03, 0x06, 0x1D, 0xF3, 0x0F, 0xFF ; Caractere 38
 DB 0xBE, 0x7E, 0x7E, 0xFE, 0xFC, 0xFC, 0xFD, 0xF9 ; Caractere 39
 DB 0xFF, 0xFC, 0xFD, 0xFD, 0xFD, 0xFD, 0xFD, 0xFC ; Caractere 3A
 DB 0xE9, 0x09, 0xF9, 0x01, 0x01, 0x01, 0xFF, 0x00 ; Caractere 3B
 DB 0x7E, 0x7E, 0x7F, 0x7F, 0x7F, 0x7E, 0xFE, 0x7E ; Caractere 3C
 DB 0xFE, 0x01, 0xFF, 0xFF, 0xFF, 0xFE, 0x7F, 0x3F ; Caractere 3D
 DB 0x7E, 0xFE, 0xFC, 0xF9, 0xE2, 0x0C, 0x30, 0x90 ; Caractere 3E
 DB 0x40, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00, 0x00 ; Caractere 3F
 DB 0x02, 0x02, 0x02, 0x02, 0x02, 0x03, 0x00, 0x00 ; Caractere 40
 DB 0xFD, 0xFC, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0x00 ; Caractere 41
 DB 0xFF, 0x00, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0x00 ; Caractere 42
 DB 0x9F, 0x3F, 0xFF, 0xFC, 0x01, 0xFE, 0x00, 0x00 ; Caractere 43
 DB 0xD1, 0x9C, 0x23, 0x40, 0x80, 0x00, 0x00, 0x00 ; Caractere 44
 DB 0xFF, 0xFF, 0x0F, 0xE0, 0x1E, 0x01, 0x00, 0x00 ; Caractere 45
 DB 0xFF, 0xFF, 0xFF, 0xF8, 0x03, 0xFC, 0x00, 0x00 ; Caractere 46
 DB 0xFC, 0xF9, 0x86, 0x38, 0xC0, 0x00, 0x00, 0x00 ; Caractere 47
 DB 0x67, 0x91, 0x0C, 0x03, 0x00, 0x00, 0x00, 0x00 ; Caractere 48
 DB 0xFF, 0xFF, 0x7F, 0x0C, 0xC0, 0x3F, 0x00, 0x00 ; Caractere 49
 DB 0xF9, 0xE2, 0x8E, 0x32, 0xC2, 0x02, 0x02, 0x02 ; Caractere 4A
 DB 0xFD, 0xFD, 0xFD, 0xFC, 0xFF, 0xFF, 0xFF, 0xFF ; Caractere 4B
 DB 0x05, 0x05, 0xFF, 0x00, 0xFE, 0xFE, 0xFE, 0xFE ; Caractere 4C
 DB 0xFF, 0xFF, 0xFF, 0xFF, 0x80, 0xFF, 0x80, 0x80 ; Caractere 4D
 DB 0xFF, 0xFF, 0xFF, 0xFC, 0x01, 0xFE, 0x00, 0x00 ; Caractere 4E
 DB 0xF3, 0xE5, 0x8D, 0x35, 0xC4, 0x07, 0x00, 0x00 ; Caractere 4F
 DB 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00, 0x00 ; Caractere 50
 DB 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x01, 0x01 ; Caractere 51
 DB 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0xFE, 0x7E, 0x7E ; Caractere 52
 DB 0x9F, 0xCF, 0xA7, 0x93, 0x89, 0x84, 0x82, 0x81 ; Caractere 53
 DB 0xC8, 0xE4, 0xF2, 0xF9, 0xFC, 0xFE, 0x7F, 0x3F ; Caractere 54
 DB 0x00, 0x00, 0x00, 0x00, 0x80, 0x40, 0x20, 0xA0 ; Caractere 55
 DB 0x00, 0x00, 0x00, 0x00, 0xF0, 0x0C, 0xE3, 0xF8 ; Caractere 56
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x80 ; Caractere 57
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x3F, 0x40, 0x8F ; Caractere 58
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0xFC, 0x02, 0xF1 ; Caractere 59
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x06, 0x08 ; Caractere 5A
 DB 0x00, 0x00, 0x00, 0x0F, 0x70, 0x87, 0x3F, 0xFF ; Caractere 5B
 DB 0x02, 0x03, 0x00, 0xFC, 0x03, 0xF8, 0xFF, 0xFF ; Caractere 5C
 DB 0x00, 0xFF, 0x00, 0x00, 0x80, 0x61, 0x19, 0xC5 ; Caractere 5D
 DB 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x7E ; Caractere 5E
 DB 0x80, 0x80, 0x00, 0x00, 0x00, 0x81, 0x81, 0x81 ; Caractere 5F
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x00, 0x7E ; Caractere 60
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x80, 0x80, 0x80 ; Caractere 61
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0xFF, 0x80, 0xBF ; Caractere 62
 DB 0x01, 0x01, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFF ; Caractere 63
 DB 0x00, 0xFF, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFF ; Caractere 64
 DB 0x80, 0x80, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFF ; Caractere 65
 DB 0x80, 0x7F, 0x00, 0x00, 0x00, 0xFF, 0x00, 0xFE ; Caractere 66
 DB 0x20, 0xE0, 0x00, 0x00, 0x00, 0x80, 0x80, 0x80 ; Caractere 67
 DB 0x02, 0x02, 0x02, 0x03, 0x00, 0x00, 0x00, 0x00 ; Caractere 68
 DB 0xFF, 0xFF, 0x1F, 0xDF, 0x5F, 0x5F, 0x5F, 0x5F ; Caractere 69
 DB 0xFF, 0xFF, 0x80, 0xBF, 0xA0, 0xA0, 0xA0, 0xA0 ; Caractere 6A
 DB 0xFF, 0xFF, 0x03, 0xFC, 0x07, 0x01, 0x00, 0x00 ; Caractere 6B
 DB 0xFE, 0xFF, 0xFF, 0xFF, 0x3F, 0x9F, 0xDF, 0x6F ; Caractere 6C
 DB 0x40, 0x21, 0xA1, 0x92, 0xD4, 0xCD, 0xE9, 0xE7 ; Caractere 6D
 DB 0x9F, 0x3F, 0x7F, 0x7E, 0xFC, 0xF9, 0xFA, 0xF2 ; Caractere 6E
 DB 0xF9, 0xFC, 0xFE, 0x7E, 0x3F, 0x9F, 0x5F, 0x4F ; Caractere 6F
 DB 0x13, 0xA7, 0xCF, 0x5F, 0x3F, 0xBF, 0x9F, 0xCF ; Caractere 70
 DB 0xF8, 0xE3, 0xCC, 0x90, 0xA0, 0xA0, 0x90, 0xCC ; Caractere 71
 DB 0x0F, 0xE1, 0x1C, 0x03, 0x00, 0x00, 0x00, 0x00 ; Caractere 72
 DB 0xF3, 0xE5, 0x49, 0x91, 0x61, 0x01, 0x01, 0x01 ; Caractere 73
 DB 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7F ; Caractere 74
 DB 0x81, 0x81, 0x81, 0x81, 0x81, 0xFF, 0x00, 0xFF ; Caractere 75
 DB 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0xFE ; Caractere 76
 DB 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80 ; Caractere 77
 DB 0xBF, 0xBF, 0x87, 0xF7, 0x17, 0x17, 0x17, 0x17 ; Caractere 78
 DB 0xFF, 0xFF, 0xE0, 0xEF, 0xE9, 0xE9, 0xE9, 0xE9 ; Caractere 79
 DB 0xFF, 0xFF, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F ; Caractere 7A
 DB 0xFF, 0xFF, 0x03, 0x7B, 0x4B, 0x4B, 0x4B, 0x4B ; Caractere 7B
 DB 0xFE, 0xFE, 0xF0, 0xF7, 0xF4, 0xF4, 0xF4, 0xF4 ; Caractere 7C
 DB 0x80, 0x80, 0x80, 0x80, 0x00, 0x00, 0x00, 0x00 ; Caractere 7D
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03 ; Caractere 7E
 DB 0x5F, 0x5F, 0x5F, 0x5F, 0x5F, 0x5F, 0x5F, 0xDF ; Caractere 7F
 DB 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0xA0, 0xBF ; Caractere 80
 DB 0x00, 0x00, 0x00, 0x00, 0x00, 0x01, 0x07, 0xFC ; Caractere 81
 DB 0x2F, 0x2F, 0x2F, 0x6F, 0xDF, 0x9F, 0x3F, 0xFF ; Caractere 82
 DB 0xE7, 0xE7, 0xE7, 0xE7, 0xEF, 0xCF, 0xDF, 0x9F ; Caractere 83
 DB 0xE4, 0xE4, 0xC8, 0x9F, 0x80, 0xFF, 0xFF, 0xFF ; Caractere 84
 DB 0x27, 0x27, 0x13, 0xF9, 0x01, 0xFF, 0xFF, 0xFF ; Caractere 85
 DB 0xEF, 0xE7, 0xF2, 0xFA, 0xF9, 0xFC, 0xFE, 0xFE ; Caractere 86
 DB 0xE3, 0xF8, 0xFF, 0x3F, 0x8F, 0xE0, 0x9E, 0x41 ; Caractere 87
 DB 0xFE, 0x01, 0xFC, 0xFF, 0xFF, 0xFF, 0x00, 0xFF ; Caractere 88
 DB 0x01, 0xE1, 0x19, 0xE7, 0xF9, 0xFE, 0x3F, 0xCF ; Caractere 89
 DB 0x7F, 0x7F, 0x7F, 0x7F, 0x7E, 0xFE, 0x3E, 0x9E ; Caractere 8A
 DB 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x81, 0x81 ; Caractere 8B
 DB 0xFE, 0xFE, 0xFE, 0xFE, 0x7E, 0x7E, 0x7E, 0x7E ; Caractere 8C
 DB 0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17, 0x17 ; Caractere 8D
 DB 0xE9, 0xE9, 0xE9, 0xE9, 0xE9, 0xE9, 0xE9, 0xE9 ; Caractere 8E
 DB 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F, 0x7F ; Caractere 8F
 DB 0x4B, 0x4B, 0x4B, 0x4B, 0x4B, 0x4B, 0x4B, 0x4B ; Caractere 90
 DB 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4, 0xF4 ; Caractere 91
 DB 0x02, 0x02, 0x02, 0x02, 0x02, 0x02, 0x03, 0x00 ; Caractere 92
 DB 0x1F, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00 ; Caractere 93
 DB 0x80, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00 ; Caractere 94
 DB 0x03, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00 ; Caractere 95
 DB 0xFF, 0xFF, 0xFE, 0xF8, 0xE3, 0x0C, 0xFF, 0x00 ; Caractere 96
 DB 0xBC, 0x39, 0x71, 0xF2, 0xE4, 0x04, 0xF8, 0x00 ; Caractere 97
 DB 0x00, 0xFF, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00 ; Caractere 98
 DB 0x3F, 0x9F, 0x8F, 0x4F, 0x27, 0x20, 0x1F, 0x00 ; Caractere 99
 DB 0x20, 0xA0, 0x98, 0xCE, 0xE9, 0x04, 0xFF, 0x87 ; Caractere 9A
 DB 0x27, 0x17, 0x17, 0x67, 0x8F, 0x3F, 0xFE, 0xFC ; Caractere 9B
 DB 0xDE, 0xCE, 0xEE, 0xCE, 0xDE, 0x90, 0x3F, 0xC0 ; Caractere 9C
 DB 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x81, 0x00 ; Caractere 9D
 DB 0x7E, 0x7E, 0x7E, 0x7E, 0x7E, 0x00, 0xFF, 0x00 ; Caractere 9E
 DB 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x80, 0x00 ; Caractere 9F
 DB 0xF7, 0x87, 0xBF, 0xBF, 0xBF, 0x80, 0xFF, 0x00 ; Caractere A0
 DB 0xEF, 0xE0, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00 ; Caractere A1
 DB 0x7F, 0x7F, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00 ; Caractere A2
 DB 0x7B, 0x03, 0xFF, 0xFF, 0xFF, 0x00, 0xFF, 0x00 ; Caractere A3
 DB 0xF7, 0xF0, 0xFE, 0xFE, 0xFE, 0x00, 0xFF, 0x00 ; Caractere A4
 DB 0x70, 0x0E, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00 ; Caractere A5
 DB 0xE1, 0x0E, 0xF0, 0x00, 0x00, 0x00, 0x00, 0x00 ; Caractere A6
 DB 0x00, 0x04, 0x0C, 0x1C, 0x3C, 0x3C, 0x7C, 0xFC ; Caractere A7
 DB 0x00, 0x00, 0x00, 0xFF, 0x7F, 0x1F, 0x0F, 0x03 ; Caractere A8
 DB 0x00, 0x01, 0x03, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF ; Caractere A9
 DB 0xFC, 0xFC, 0xFC, 0xFF, 0xFF, 0xFF, 0xFF, 0xFF ; Caractere AA
 DB 0x00, 0x00, 0x00, 0xFF, 0xFC, 0xF8, 0xE0, 0xE0 ; Caractere AB
 DB 0x00, 0x00, 0x00, 0x7F, 0xFF, 0xFF, 0xF0, 0xF0 ; Caractere AC
 DB 0x00, 0x00, 0x00, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C ; Caractere AD
 DB 0x00, 0x00, 0x00, 0x7F, 0x7F, 0x7F, 0x78, 0x78 ; Caractere AE
 DB 0x00, 0x00, 0x00, 0xF0, 0xF8, 0xF8, 0x78, 0x78 ; Caractere AF
 DB 0x00, 0x00, 0x00, 0x7F, 0xFF, 0xFF, 0xE0, 0xE0 ; Caractere B0
 DB 0x00, 0x00, 0x00, 0xCF, 0xCF, 0xCF, 0x0F, 0x00 ; Caractere B1
 DB 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0xF0 ; Caractere B2
 DB 0x00, 0x00, 0x00, 0x3F, 0x3F, 0x3F, 0x3F, 0x00 ; Caractere B3
 DB 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00 ; Caractere B4
 DB 0x01, 0x00, 0x01, 0x03, 0x03, 0x07, 0x0F, 0x0F ; Caractere B5
 DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFC, 0xF0, 0xC0, 0x80 ; Caractere B6
 DB 0xFF, 0xFF, 0xFF, 0xFF, 0x7F, 0x1F, 0x07, 0x01 ; Caractere B7
 DB 0xFF, 0xFF, 0xFF, 0xFF, 0xFC, 0x7E, 0x3F, 0x3F ; Caractere B8
 DB 0xFC, 0xFC, 0xFC, 0xFC, 0x00, 0x00, 0x00, 0x00 ; Caractere B9
 DB 0xFF, 0xFF, 0xFF, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0 ; Caractere BA
 DB 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C, 0x3C ; Caractere BB
 DB 0x7F, 0x7F, 0x7F, 0x79, 0x78, 0x78, 0x78, 0x78 ; Caractere BC
 DB 0xF8, 0xF0, 0xE0, 0xE0, 0xF0, 0xF0, 0xF0, 0x78 ; Caractere BD
 DB 0xFF, 0xFF, 0x7F, 0x01, 0x01, 0xFF, 0xFF, 0xFF ; Caractere BE
 DB 0x80, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0xC0, 0x80 ; Caractere BF
 DB 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0 ; Caractere C0
 DB 0x00, 0x00, 0x0F, 0x10, 0x17, 0x14, 0x17, 0x10 ; Caractere C1
 DB 0x00, 0x00, 0x84, 0x44, 0x44, 0x44, 0x44, 0x44 ; Caractere C2
 DB 0x00, 0x00, 0xF3, 0x92, 0x92, 0xF3, 0x12, 0x12 ; Caractere C3
 DB 0x00, 0x00, 0xCF, 0x48, 0x48, 0xCF, 0x49, 0x49 ; Caractere C4
 DB 0x1E, 0x38, 0x30, 0x00, 0x00, 0x00, 0x00, 0x00 ; Caractere C5
 DB 0x00, 0x00, 0x7F, 0xFF, 0xFF, 0xFF, 0xFC, 0x7E ; Caractere C6
 DB 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00 ; Caractere C7
 DB 0x1F, 0x0F, 0x07, 0x07, 0x03, 0x01, 0x00, 0x00 ; Caractere C8
 DB 0x80, 0xC0, 0xE0, 0xE0, 0xF0, 0xF8, 0xFC, 0xFC ; Caractere C9
 DB 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x00, 0x00, 0x00 ; Caractere CA
 DB 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0x1E, 0x1E, 0x1E ; Caractere CB
 DB 0x00, 0x00, 0xFC, 0xFC, 0xFC, 0x00, 0x00, 0x00 ; Caractere CC
 DB 0x00, 0x00, 0x7F, 0xFF, 0xFF, 0xF0, 0xF0, 0xF0 ; Caractere CD
 DB 0x00, 0x00, 0xF0, 0xF8, 0xF8, 0x78, 0x78, 0x78 ; Caractere CE
 DB 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xF0, 0xF0, 0xF0 ; Caractere CF
 DB 0x00, 0x00, 0xE0, 0xF0, 0xF0, 0xF0, 0xF0, 0xF0 ; Caractere D0
 DB 0x0F, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00 ; Caractere D1
 DB 0x84, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00 ; Caractere D2
 DB 0xF3, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00 ; Caractere D3
 DB 0xCF, 0x00, 0xFF, 0xFF, 0xFF, 0xFF, 0x00, 0x00 ; Caractere D4
 DB 0x7E, 0x3F, 0x1F, 0x1F, 0x0F, 0x07, 0x03, 0x03 ; Caractere D5
 DB 0x00, 0x00, 0x80, 0xC0, 0xC0, 0xE0, 0xF0, 0xF0 ; Caractere D6
 DB 0x7E, 0x3F, 0xFF, 0xFF, 0xFF, 0xFE, 0x00, 0x00 ; Caractere D7
 DB 0x1E, 0x1E, 0x1E, 0x1E, 0x1E, 0x1E, 0x00, 0x00 ; Caractere D8
 DB 0xFF, 0xFF, 0xF0, 0xF0, 0xF0, 0xF0, 0x00, 0x00 ; Caractere D9
 DB 0xF8, 0xF8, 0x78, 0x78, 0x78, 0x78, 0x00, 0x00 ; Caractere DA
 DB 0xFF, 0xFF, 0xF3, 0xF0, 0xF0, 0xF0, 0x00, 0x00 ; Caractere DB
 DB 0xF0, 0x80, 0xE0, 0xE0, 0xF8, 0xF8, 0x00, 0x00 ; Caractere DC
 DB 0x00, 0x00, 0x00, 0xEE, 0x4E, 0x4A, 0x00, 0x00 ; Caractere DD
 DB 0x00, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF ; Caractere DE
 DB 0x01, 0x00, 0x00, 0x00, 0xFF, 0xFF, 0xFF, 0xFF ; Caractere DF
 DB 0xF8, 0xFC, 0xFC, 0x7E, 0xFE, 0xFE, 0xFE, 0xFC ; Caractere E0
 DB 0x00, 0x1E, 0x3F, 0x33, 0x33, 0x33, 0x3F, 0x1E ; Caractere E1
 DB 0x00, 0x3E, 0x3E, 0x30, 0x3C, 0x3C, 0x30, 0x30 ; Caractere E2
 DB 0x00, 0x7E, 0x7E, 0x18, 0x18, 0x18, 0x18, 0x18 ; Caractere E3
 DB 0x00, 0x60, 0x60, 0x66, 0x66, 0x66, 0x7F, 0x7F ; Caractere E4
 DB 0x00, 0x63, 0x67, 0x66, 0x66, 0x67, 0xE7, 0xE6 ; Caractere E5
 DB 0x00, 0xE3, 0xF3, 0x33, 0x33, 0xF3, 0xF3, 0x33 ; Caractere E6
 DB 0x00, 0xE3, 0xF3, 0x33, 0xE3, 0xF3, 0x33, 0x33 ; Caractere E7
 DB 0x00, 0xF0, 0xF0, 0x00, 0xE0, 0x00, 0xF0, 0xF0 ; Caractere E8
 DB 0x00, 0xA4, 0xB5, 0xB5, 0xAD, 0xAD, 0xA5, 0xA4 ; Caractere E9
 DB 0x00, 0x80, 0x40, 0x00, 0x00, 0x00, 0x40, 0x80 ; Caractere EA
