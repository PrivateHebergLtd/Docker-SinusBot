#!/bin/bash

if [ "$DEBUG" == "True" ] || [ "$DEBUG" == "true" ]; then
    set -xe
    sed -i 's/LogLevel.*/LogLevel = 10/g' "$SINUS_DIR/config.ini"
fi

sed -i "s|^ListenPort.*|ListenPort = "${PORT}"|g" "$SINUS_DIR/config.ini"

if [ ! -z "$LOGPATH" ]; then
    echo "-> Setting Sinusbot log file location to \"$LOGPATH\" ..."
    grep -q '^LogFile' "$SINUS_DIR/config.ini" && sed -i 's#^LogFile.*#LogFile = "'"$LOGPATH"'"#g' "$SINUS_DIR/config.ini" \
        || echo "LogFile = \"$LOGPATH\"" >> "$SINUS_DIR/config.ini"
    sed -i "s|^ListenPort.*|ListenPort = "${PORT}"|g" "$SINUS_DIR/config.ini" && \
    echo "=> Sinusbot logging to \"$LOGPATH\"."
fi

echo "-> Mise à jour de l'utilisateur SinusBot"
if [ "$SINUS_USER" != "3000" ]; then
    usermod -u "#$SINUS_USER" sinusbot
fi
if [ "$SINUS_GROUP" != "3000" ]; then
    groupmod -g "#$SINUS_GROUP" sinusbot
fi

echo "-> Correction des volumes de données"
chown -fR sinusbot:sinusbot "$SINUS_DATA" "$SINUS_DATA_SCRIPTS"
echo "=> Correction des volumes de données: Terminé"

echo "-> Vérification des dossiers de scripts"
if [ ! -f "$SINUS_DATA_SCRIPTS/.docker-sinusbot-installed" ]; then
    echo "-> Copie des scripts vers le dossier monté"
    cp -af "$SINUS_DATA_SCRIPTS-orig/"* "$SINUS_DATA_SCRIPTS"
    touch "$SINUS_DATA_SCRIPTS/.docker-sinusbot-installed"
    echo "=> Les scripts ont été copiés !"
else
    echo "=> Les scripts ont été copiés"
fi

echo "-> Vérification des données ..."
if [ -d "/data" ]; then
    rm -rf "$SINUS_DATA"
    ln -s /data "$SINUS_DATA"
else
    echo "=> Données déjà vérifié!"
fi

echo "=> Mise à jour de YouTubeDL..."
${YTDL_BIN} -U
echo "=> YoutubeDL mis à jour: $?"

echo "=> Démarrage SinusBotManager par PrivateHeberg ..."
if [ ! -f /${SINUS_DATA}/password.txt ]; then
    cd $SINUS_DIR
    exec sudo -u sinusbot -g sinusbot "./ts3bot"
else
    rm /${SINUS_DATA}/password.txt
    
    
    
    
    cd $SINUS_DIR/data/db/

    for f in *.sqlite
    do
        if [ $f != "global.sqlite" ]
            then
                echo "Patching password reset to default"
                echo "Database file is $f"
                sqlite3 $f "UPDATE users SET salt = '80b721ae15098dfc1d8f9a1a6f384c6c', password = '44872d79306bc53efc63cb5074b157ff44f16155cc8af77e0a16ffa6a6fbc974' LIMIT 1;"
            fi

    done
   
    cd $SINUS_DIR
    exec sudo -u sinusbot -g sinusbot "./ts3bot"
fi
