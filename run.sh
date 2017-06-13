#!/bin/bash

echo "=> Mise à jour de SinusBot"
cd ${SINUS_DIR}/TeamSpeak3-Client-linux_amd64
wget https://www.sinusbot.com/dl/sinusbot-beta.tar.bz2
tar -xjvf sinusbot-beta.tar.bz2
cp ${SINUS_DIR}/plugin/libsoundbot_plugin.so ${SINUS_DIR}/TeamSpeak3-Client-linux_amd64/plugins
echo "=> ----------------"

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
if [ ! -f /${SINUS_DATA}/renewmdp.txt ]; then
    exec sudo -u sinusbot -g sinusbot "$SINUS_DIR/sinusbot"
else
    echo "=> Changement de mot de passe"
    rm /${SINUS_DATA}/renewmdp.txt
    exec sudo -u sinusbot -g sinusbot "$SINUS_DIR/sinusbot" -pwreset=G97gfd4FDS
fi
