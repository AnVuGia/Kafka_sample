#!/bin/bash

# Script to create a sample topic in Kafka
# This can be run manually if needed, but docker-compose will handle it automatically

echo "Waiting for Kafka to be ready..."
until docker exec kafka kafka-broker-api-versions --bootstrap-server localhost:9092 2>/dev/null; do
  echo "Waiting for Kafka broker..."
  sleep 2
done

echo "Creating sample topic: sample-topic"
docker exec kafka /opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic sample-topic \
  --if-not-exists

echo "Listing all topics:"
docker exec kafka /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092

echo "Topic setup complete!"

