#!/bin/bash

source ./address.sh

add=""
exp=""
exp2=""

HEIGHT=40
WIDTH=60
CHOICE_HEIGHT=50

OPTIONS=(1 "BOB_LEPONGE"
         2 "ALICE_AU_PAYS_DES_MERVEILLES"
         3 "HARRY_POTTER")

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
  case $CHOICE in
          1)
              exp=$BOB_LEPONGE
              ;;
          2)
              exp=$ALICE_AU_PAYS_DES_MERVEILLES
              ;;
          3)
              exp=$HARRY_POTTER
              ;;
  esac

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
  case $CHOICE in
          1)
              add=$BOB_LEPONGE
              ;;
          2)
              add=$ALICE_AU_PAYS_DES_MERVEILLES
              ;;
          3)
              add=$HARRY_POTTER
              ;;
  esac

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
      left: 160mm;
      top: 70mm;
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
