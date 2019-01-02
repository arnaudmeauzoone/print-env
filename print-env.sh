#!/bin/bash

set -e

# Reset
NC='\033[0m'              # Text Reset

# Regular Colors
Black='\033[0;30m'        # Black
Red='\033[0;31m'          # Red
Green='\033[0;32m'        # Green
Yellow='\033[0;33m'       # Yellow
Blue='\033[0;34m'         # Blue
Purple='\033[0;35m'       # Purple
Cyan='\033[0;36m'         # Cyan
White='\033[0;37m'        # White

# Bold
BBlack='\033[1;30m'       # Black
BRed='\033[1;31m'         # Red
BGreen='\033[1;32m'       # Green
BYellow='\033[1;33m'      # Yellow
BBlue='\033[1;34m'        # Blue
BPurple='\033[1;35m'      # Purple
BCyan='\033[1;36m'        # Cyan
BWhite='\033[1;37m'       # White

# Underline
UBlack='\033[4;30m'       # Black
URed='\033[4;31m'         # Red
UGreen='\033[4;32m'       # Green
UYellow='\033[4;33m'      # Yellow
UBlue='\033[4;34m'        # Blue
UPurple='\033[4;35m'      # Purple
UCyan='\033[4;36m'        # Cyan
UWhite='\033[4;37m'       # White

# Background
On_Black='\033[40m'       # Black
On_Red='\033[41m'         # Red
On_Green='\033[42m'       # Green
On_Yellow='\033[43m'      # Yellow
On_Blue='\033[44m'        # Blue
On_Purple='\033[45m'      # Purple
On_Cyan='\033[46m'        # Cyan
On_White='\033[47m'       # White

# High Intensity
IBlack='\033[0;90m'       # Black
IRed='\033[0;91m'         # Red
IGreen='\033[0;92m'       # Green
IYellow='\033[0;93m'      # Yellow
IBlue='\033[0;94m'        # Blue
IPurple='\033[0;95m'      # Purple
ICyan='\033[0;96m'        # Cyan
IWhite='\033[0;97m'       # White

# Bold High Intensity
BIBlack='\033[1;90m'      # Black
BIRed='\033[1;91m'        # Red
BIGreen='\033[1;92m'      # Green
BIYellow='\033[1;93m'     # Yellow
BIBlue='\033[1;94m'       # Blue
BIPurple='\033[1;95m'     # Purple
BICyan='\033[1;96m'       # Cyan
BIWhite='\033[1;97m'      # White

# High Intensity backgrounds
On_IBlack='\033[0;100m'   # Black
On_IRed='\033[0;101m'     # Red
On_IGreen='\033[0;102m'   # Green
On_IYellow='\033[0;103m'  # Yellow
On_IBlue='\033[0;104m'    # Blue
On_IPurple='\033[0;105m'  # Purple
On_ICyan='\033[0;106m'    # Cyan
On_IWhite='\033[0;107m'   # White

declare VERBOSE
readonly DEFAULT_VERBOSE=2
readonly -A LOG_LEVELS=([0]="Null" [1]="${BIRed}error${NC}" [2]="${BIGreen}info${NC}" [3]="${BIGreen}info${NC}" [4]="${BIBlue}debug${NC}")

## Some files
readonly BLACKHOLE='/dev/null'
readonly TMP_DIR=$(mktemp -d -p "$(pwd)")

## Usefull Var
declare RETVAL
declare RETERR
readonly ERROR=$RANDOM
readonly TRUE=$RANDOM
readonly FALSE=$RANDOM
declare DO_USAGE=$FALSE
declare DO_VERSION=$FALSE
declare DO_ERRPAR=$FALSE
declare ERRPAR

declare INFO_MESSAGE=$TRUE

#Program DATA
readonly PROG_NAME="$(basename "${0}")"
readonly VERSION="0.0.1"

source ./address.sh

declare PRINTER="HP_ENVY_5640_series"
readonly DEFAUT_PRINTER="HP_ENVY_5640_series"
readonly MEDIA='EnvDLA'

readonly TMP_HTML=$TMP_DIR/"tmp.html"
readonly TMP_PDF=$TMP_DIR/"tmp.pdf"

declare USR_EXP_ADDR=""
declare USR_DEST_ADDR=""
declare DEST_ADDR="" #Contient l'adresse du destinataire
declare EXP_ADDR="" #Contient l'adress de l'expéditeur au recto de l'enveloppe
declare EXP_ADDR2="" #Contient l'adress de l'expéditeur au verso de l'enveloppe
declare ALL_ADDR=""
declare DIALOGUE=$FALSE
declare SHOW_LIST=$FALSE
readonly PREFIX_ADDR="ADDR_"
declare DIALOGUE_OPTIONS=""

readonly CMD_WKHTMLTOPDF="wkhtmltopdf"
readonly CMD_LP="lp"
readonly CMD_DIALOG="dialog"


readonly HEIGHT=17 #Hauteur de la fenetre de dialogue
readonly WIDTH=60 #Largeur de la fenetre de dialogue
readonly CHOICE_HEIGHT=50 #Hauteur de la fenetre de choix

usage(){

  info "Usage: $PROG_NAME -e <expediteur> -d <destinataire> [-ilnhvV]"
  info ""
  info "Imprime votre adresse et l'adresse du destinataire sur"
  info "Une Enveloppe"
  info ""
  info "-e             indique l' expéditeur"
  info "-d             indique le destinataire"
  info "-i             Permet d'avoir une interface graphique"
  info "-l             Liste les adresses disponibles"
  info "-v             indique la version du programme"
  info "-h             affiche l'aide"
  info "-V             change la verbosité (defaut == 2)"
  info "               -V 0: n'affiche rien du tout"
  info "               -V 1: n'affiche que les erreurs"
  info "               -V 2: affiche les informations essentiels"
  info "               -V 3: affiche plus d'informations"
  info "               -V 4: affiche les commandes utilisées (debug)"
  info "-n             Supprime les méssages: [${BIRed}error${NC}], [${BIGreen}info${NC}] et [${BIBlue}debug${NC}]"
  info ""
  info "Exemple:"
  info ""
  info "        ./print-env.sh -e BOB_LEPONGE -d HARRY_POTTER"
  info "        ./print-env.sh -h"
  info "        ./print-env.sh -i"
  info "        ./print-env.sh -l"

}

version(){

  info "$PROG_NAME: $VERSION"

}

.log () {
  local LEVEL=${1}
  shift
  if [ "${VERBOSE}" -ge "${LEVEL}" ]; then
    if [ $INFO_MESSAGE = $TRUE ]; then
      if [ $LEVEL -eq "1" ]; then
        >&2 echo -e "[${LOG_LEVELS[$LEVEL]}]" "$@"
      else
        echo -e "[${LOG_LEVELS[$LEVEL]}]" "$@"
      fi
    else
      if [ $LEVEL -eq "1" ]; then
        >&2 echo -e "$@"
      else
        echo -e "$@"
      fi
    fi
  fi
}

do_cmd()
{
    .log 2 $2
    .log 4 "Command [ ${On_Blue}$1${NC} ]"

    if [ ! -z $3 ]; then
      set +e
    fi

    RETVAL="$($1 2>$BLACKHOLE)"

    RETERR=$?
    set -e
    if [[ $RETERR -eq 0 ]]
    then
        .log 4 "Successfully ran [ ${On_Blue}$1${NC} ]"
        .log 3 "$2: ${On_Green}Done!${NC}"
    else
        RETVAL=$ERROR
        .log 1 "$2: ${On_Red}ECHEC!${NC}"
        .log 4 "Command [ ${On_Red}$1${NC} ]"
    fi
}

error(){

  .log 1 "${On_Red}$1${NC}"

  if [ ! -z $2 ]; then
    $2
  fi
  exit 1

}

info(){

  .log 2 "$1"

}

info_v(){

  .log 3 "$1"

}

remove_temp_files(){

  do_cmd "rm -rf ${TMP_DIR}" \
  "Cleaning Files"
  exit 1

}

check_all () {

  local aux ALL_CMD RESULT_CMD

  aux=${!CMD_*}
  ALL_CMD=( ${aux} )

  for each in "${ALL_CMD[@]}"
  do
    set +e
    command -v ${!each} > $BLACKHOLE
    RESULT_CMD=$?
    set -e
    if [ ! $RESULT_CMD -eq 0 ]; then
      error "${!each} n'est pas installé sur votre systeme !"
    fi
  done

}

parse_options(){

  local OPTIND
  while getopts :e:d:V:ilnhv OPT
  do
    case "${OPT}" in
        n)
            INFO_MESSAGE=$FALSE
            ;;
        h)
            DO_USAGE=$TRUE
            break
            ;;
        v)
            DO_VERSION=$TRUE
            break
            ;;
        i)
            DIALOGUE=$TRUE
            break
            ;;
        l)
            SHOW_LIST=$TRUE
            break
            ;;
        V)
            local V=${OPTARG}
            ;;
        d)
            local d=${OPTARG}
            ;;
        e)
            local e=${OPTARG}
            ;;
        :)
            ERRPAR=$OPTARG
            DO_ERRPAR=$TRUE
            break
            ;;
        *)
            DO_USAGE=$TRUE
            break
            ;;
    esac
  done

  case $V in
      0|1|2|3|4) readonly VERBOSE=$V;;
      *)         readonly VERBOSE=$DEFAULT_VERBOSE;;
  esac

  if [ -z "$*" ]; then
    usage
    exit 0
  fi

  if [ $DO_USAGE = $TRUE ]; then
    usage
    exit 0
  fi

  if [ $DO_VERSION = $TRUE ]; then
    version
    exit 0
  fi

  if [ $DO_ERRPAR = $TRUE ]; then
    .log 1 "The additional argument for option $ERRPAR was omitted."
    usage
    exit 1
  fi

  if [ $SHOW_LIST = $TRUE ]; then
    get_addresses
    show_list
    exit 0
  fi

  if [ ! -z "${e}" ] && [ ! -z "${d}" ]; then
    readonly ARG_EXP_ADDR="${e}"
    readonly ARG_DEST_ADDR="${d}"
  fi

}

show_list () {

  info "Les adresses disponibles sont:"
  info ""

  for each in "${ALL_ADDR[@]}"
  do
    info "$each"
  done

  info ""
  info "Pour ajouter plus d'adresses voir le fichier address.sh"

}

get_addresses () {

  ## Create an array from adrress.sh
  ## Each case on $ALL_ADDR as an adress
  ## from address.sh

  local aux=${!ADDR_*}
  readonly ALL_ADDR=( ${aux//ADDR_/} )

}

create_options () {

  DIALOGUE_OPTIONS=( $(local counter="1"

  for each in "${ALL_ADDR[@]}"
  do
    echo "$counter $each"
    ((counter+=1))
  done) )

}

use_dialogue_exp () {

  local BACKTITLE="Imprim Enveloppe" #Le titre en arrière plan
  local TITLE="Imprim Enveloppe" #Le titre en haut de la fenetre
  local MENU="Qui envoie l'enveloppe ?" #La question sur le menu

  local CHOICE=$($CMD_DIALOG --clear \
                  --backtitle "$BACKTITLE" \
                  --title "$TITLE" \
                  --menu "$MENU" \
                  $HEIGHT $WIDTH $CHOICE_HEIGHT \
                  "${DIALOGUE_OPTIONS[@]}" \
                  2>&1 >/dev/tty)

  RETVAL=${DIALOGUE_OPTIONS[$(("${CHOICE}" * 2)) - 1]} #Permet de récupérer l'index du choix dans le tableau

  clear # Efface l'écrant


}

choix_expediteur () {

  if [ $DIALOGUE = $TRUE ]; then
    use_dialogue_exp
    USR_EXP_ADDR=$RETVAL
  else
    USR_EXP_ADDR=$ARG_EXP_ADDR
  fi

  if [[ " ${ALL_ADDR[@]} " =~ " ${USR_EXP_ADDR} " ]]; then
    local AUX=$PREFIX_ADDR$USR_EXP_ADDR
    EXP_ADDR=${!AUX}
    EXP_ADDR2=$(echo "$EXP_ADDR" | tr -d "<br>")
  else
    error "L'adresse expéditeur: ${USR_EXP_ADDR} donnée en parametre est inconnue" "show_list"
  fi

}

use_dialogue_dest () {

  local BACKTITLE="Imprim Enveloppe" #Le titre en arrière plan
  local TITLE="Imprim Enveloppe" #Le titre en haut de la fenetre
  local MENU="A quelle adresse envoyer l'envellope ?" #La question sur le menu

  local CHOICE=$($CMD_DIALOG --clear \
                  --backtitle "$BACKTITLE" \
                  --title "$TITLE" \
                  --menu "$MENU" \
                  $HEIGHT $WIDTH $CHOICE_HEIGHT \
                  "${DIALOGUE_OPTIONS[@]}" \
                  2>&1 >/dev/tty)

  RETVAL=${DIALOGUE_OPTIONS[$(("${CHOICE}" * 2)) - 1]} #Permet de récupérer l'index du choix dans le tableau

  clear # Efface l'écrant


}

choix_destinataire () {

  if [ $DIALOGUE = $TRUE ]; then
    use_dialogue_dest
    USR_DEST_ADDR=$RETVAL
  else
    USR_DEST_ADDR=$ARG_DEST_ADDR
  fi

  if [[ " ${ALL_ADDR[@]} " =~ " ${USR_DEST_ADDR} " ]]; then
    local AUX=$PREFIX_ADDR$USR_DEST_ADDR
    DEST_ADDR=${!AUX}
  else
    show_list
    error "L'adresse expéditeur: ${USR_DEST_ADDR} donnée en parametre est inconnue" "show_list"
  fi

}

creer_html () {

  cat << _EOF_ > "${TMP_HTML}"
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
      $EXP_ADDR
    </font>
  </div>
  <div id="destinataire">
    <font size="5">
      $DEST_ADDR
    </font>
  </div>
  <div id="expediteur2">
    <font size="5">
      $EXP_ADDR2
    </font>
  </div>
  </body>
  </html>
_EOF_

}

creer_pdf () {

  do_cmd "$CMD_WKHTMLTOPDF -s DLE -O Landscape $TMP_HTML $TMP_PDF" \
         "Creation du PDF"

  # DLE le format enveloppe
  # Landscape pour mettre le PDF en portrait
  # tmp.html le fichier d'entrée
  # tmp.pdf le fichier de sortie

}

imprimer_envellope () {

  do_cmd "$CMD_LP -d $PRINTER -o media=EnvDLA -o sides=two-sided-short-edge -o landscape $TMP_PDF" \
         "Impression sur imprimante: $PRINTER"

}

main(){

parse_options "${@}"

trap remove_temp_files INT TERM HUP EXIT SIGINT

check_all

get_addresses
create_options
choix_expediteur
choix_destinataire
creer_html
creer_pdf
imprimer_envellope

}

main "${@}"
