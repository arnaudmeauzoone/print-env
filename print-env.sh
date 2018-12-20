#!/bin/bash

source ./address.sh

add="" #Contient l'adresse du destinataire
exp="" #Contient l'adress de l'expéditeur au recto de l'enveloppe
exp2="" #Contient l'adress de l'expéditeur au verso de l'enveloppe

HEIGHT=40 #Hauteur de la fenetre de dialogue
WIDTH=60 #Largeur de la fenetre de dialogue
CHOICE_HEIGHT=50 #Hauteur de la fenetre de choix

choix_expediteur () {

  BACKTITLE="Imprim Envellope"
  TITLE="Imprim Envellope"
  MENU="Qui envoie l'envellope ?"

  CHOICE=$(dialog --clear \
                  --backtitle "$BACKTITLE" \
                  --title "$TITLE" \
                  --menu "$MENU" \
                  $HEIGHT $WIDTH $CHOICE_HEIGHT \
                  "${OPTIONS[@]}" \
                  2>&1 >/dev/tty)

  clear
  aux=${OPTIONS[$(($CHOICE * 2)) - 1]}
  exp=${!aux}


  exp2=$(echo "$exp" | tr -d "<br>")

}

choix_destinataire () {

  BACKTITLE="Imprim Envellope"
  TITLE="Imprim Envellope"
  MENU="A quelle adresse envoyer l'envellope ?"

  CHOICE=$(dialog --clear \
                  --backtitle "$BACKTITLE" \
                  --title "$TITLE" \
                  --menu "$MENU" \
                  $HEIGHT $WIDTH $CHOICE_HEIGHT \
                  "${OPTIONS[@]}" \
                  2>&1 >/dev/tty)

  clear

  aux=${OPTIONS[$(($CHOICE * 2)) - 1]}
  add=${!aux}

}

creer_html () {

  cat << _EOF_ > tmp.html
  <!DOCTYPE html>
  <html>
  <head>
  <style>
  #expediteur1 {
      position: absolute;
      left: 20mm;
      top: 10mm;
  }
  #destinataire {
      position: absolute;
      left: 140mm;
      top: 60mm;
  }
  #expediteur2 {
      position: absolute;
      top: 140mm;
      left: 30mm;
  }
  </style>
  </head>
  <body>
  <div id="expediteur1">
    <font size="5">
      $exp
    </font>
  </div>
  <div id="destinataire">
    <font size="5">
      $add
    </font>
  </div>
  <div id="expediteur2">
    <font size="5">
      $exp2
    </font>
  </div>
  </body>
  </html>
_EOF_

}

creer_pdf () {

  wkhtmltopdf -s DLE -O Landscape tmp.html tmp.pdf >/dev/null 2>&1

}

imprimer_envellope () {

  lp -d HP_ENVY_5640_series -o media=EnvDLA -o sides=two-sided-short-edge -o landscape tmp.pdf >/dev/null 2>&1

}

choix_expediteur
choix_destinataire
creer_html
creer_pdf
imprimer_envellope
