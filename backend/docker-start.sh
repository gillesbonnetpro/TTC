#!/bin/bash

echo "🔍 Vérification des processus Node-RED hors Docker..."
NODE_PID=$(ps aux | grep '[n]ode-red' | awk '{print $2}')
if [ ! -z "$NODE_PID" ]; then
  echo "⚠️ Node-RED tourne en dehors de Docker (PID: $NODE_PID). Suppression..."
  sudo kill -9 $NODE_PID
else
  echo "✅ Aucun processus Node-RED parasite détecté."
fi

echo "🔍 Vérification des processus MongoDB hors Docker..."
MONGO_PID=$(ps aux | grep '[m]ongod' | awk '{print $2}')
if [ ! -z "$MONGO_PID" ]; then
  echo "⚠️ MongoDB tourne en dehors de Docker (PID: $MONGO_PID). Suppression..."
  sudo kill -9 $MONGO_PID
else
  echo "✅ Aucun processus MongoDB parasite détecté."
fi

echo "🔍 Vérification des ports 1880 et 27017..."
for PORT in 1880 27017; do
  if sudo lsof -i :$PORT | grep LISTEN &>/dev/null; then
    echo "⚠️ Port $PORT est occupé. Cela peut bloquer Docker."
  else
    echo "✅ Port $PORT est libre."
  fi
done

echo "🔍 Vérification des permissions des volumes Docker..."

# MongoDB
mkdir -p ./data/mongodb
sudo chown -R 999:999 ./data/mongodb

# Node-RED
mkdir -p ./data/nodered
sudo chown -R 1000:1000 ./data/nodered

# Permissions générales
sudo chmod -R 755 ./data

echo "🧨 Forçage des conteneurs Docker bloqués via nsenter..."
for cid in $(docker ps -q --filter "name=mongodb" --filter "name=nodered"); do
  pid=$(docker inspect --format '{{.State.Pid}}' $cid)
  echo "⚠️ Conteneur bloqué ($cid - PID: $pid). Forçage via nsenter..."
  sudo nsenter -t $pid -p -m kill -9 1
  docker rm -f $cid
done

echo "🔄 Redémarrage du service Docker..."
sudo systemctl restart docker

echo "🚀 Lancement de Docker Compose..."
docker-compose up -d

echo "✅ Stack redémarrée avec succès."
