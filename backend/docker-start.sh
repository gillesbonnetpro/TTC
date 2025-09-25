#!/bin/bash

echo "🔍 Vérification des permissions des volumes Docker..."

# MongoDB volume
if [ -d "./data/mongodb" ]; then
  echo "✅ Volume MongoDB trouvé. Application des droits 999:999..."
  sudo chown -R 999:999 ./data/mongodb
else
  echo "📁 Volume MongoDB manquant. Création..."
  mkdir -p ./data/mongodb
  sudo chown -R 999:999 ./data/mongodb
fi

# Node-RED volume
if [ -d "./data/nodered" ]; then
  echo "✅ Volume Node-RED trouvé. Application des droits 1000:1000..."
  sudo chown -R 1000:1000 ./data/nodered
else
  echo "📁 Volume Node-RED manquant. Création..."
  mkdir -p ./data/nodered
  sudo chown -R 1000:1000 ./data/nodered
fi

echo "🔐 Application des permissions générales..."
sudo chmod -R 755 ./data

echo "🚀 Lancement de Docker Compose..."
docker-compose down
docker-compose up -d

echo "✅ Stack redémarrée avec succès."
