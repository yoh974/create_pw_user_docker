#!/bin/bash
#check parameters
if [ "$#" -ne 2 ]
then
        echo "Entrer l'utilisateur ftp puis le mot de passe"
else
    #check OS
    if [[ "$OSTYPE" == "linux-gnu" ]]; then
        SUDO=sudo
    elif [[ "$OSTYPE" == "msys" ]]; then
        SUDO=""
    fi
    DOCKER_FTP_REP="/var/www/html/ftp"
    DOCKER_REP="docker_directory"
    LOCAL_REP="- .app/ftp"
    WHERE_TO_WRITE_ON_DOCKER_COMPOSE="- \.\/volumes\/pure\-ftpd\:\/etc\/pure\-ftpd"
    USER=$1
    PASSWORD=$2
    #create user
    $SUDO docker exec -it pure-ftpd sh -c "( echo $PASSWORD ; echo $PASSWORD ) | pure-pw useradd $USER -u ftpuser -d $DOCKER_FTP_REP$USER && \
    (echo $PASSWORD ; echo $PASSWORD) | pure-pw passwd $USER -m && exit" && \
    #move to docker directory and write in docker-compose.yml
    cd $DOCKER_REP && sed -i "/$WHERE_TO_WRITE_ON_DOCKER_COMPOSE/i  \
    \      $LOCAL_REP$USER:$DOCKER_FTP_REP$USER" docker-compose.yml && \
    #refresh docker, update database of pure-pw, and change right to the created folder
    $SUDO docker-compose up -d && $SUDO docker exec -it pure-ftpd sh -c "(echo $PASSWORD ; echo $PASSWORD) | pure-pw passwd $USER -m && \
    chown ftpuser:ftpgroup $DOCKER_FTP_REP$USER && exit" && cd ..
fi


