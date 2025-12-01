# Kafka Sample Repository

A ready-to-use Kafka setup with Docker Compose that automatically creates a sample topic when booted up. This repository uses **KRaft mode** (Kafka Raft), eliminating the need for Zookeeper.

## Features

- **Apache Kafka 3.7.0** running in a container with **KRaft mode** (no Zookeeper required!)
- **KRaft (Kafka Raft)**: Uses Kafka's built-in metadata management - simpler and more efficient
- **Automatic topic creation**: A sample topic (`sample-topic`) is created automatically on startup
- **Pre-configured**: Includes `server.properties` with optimized KRaft settings
- **Easy to use**: Just run `docker-compose up` and everything is configured

## Prerequisites

- Docker
- Docker Compose (or `docker compose` command)

## Project Structure

```
Kafka_sample/
├── docker-compose.yml    # Docker Compose configuration
├── server.properties      # Kafka KRaft mode configuration
├── init-topic.sh         # Manual topic creation script (optional)
├── README.md             # This file
├── .gitignore           # Git ignore rules
└── .dockerignore        # Docker ignore rules
```

## Quick Start

1. **Start the Kafka cluster:**
   ```bash
   docker-compose up -d
   ```

2. **Verify the setup:**
   ```bash
   docker exec kafka /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
   ```
   You should see `sample-topic` in the list.

3. **Stop the cluster:**
   ```bash
   docker-compose down
   ```

## Sample Topic Details

- **Topic Name**: `sample-topic`
- **Partitions**: 3
- **Replication Factor**: 1 (suitable for local development)

## Useful Commands

### List all topics
```bash
docker exec kafka /opt/kafka/bin/kafka-topics.sh --list --bootstrap-server localhost:9092
```

### Describe a topic
```bash
docker exec kafka /opt/kafka/bin/kafka-topics.sh --describe --topic sample-topic --bootstrap-server localhost:9092
```

### Produce messages
```bash
docker exec -it kafka /opt/kafka/bin/kafka-console-producer.sh --topic sample-topic --bootstrap-server localhost:9092
```

### Consume messages
```bash
docker exec -it kafka /opt/kafka/bin/kafka-console-consumer.sh --topic sample-topic --from-beginning --bootstrap-server localhost:9092
```

### Create additional topics
```bash
docker exec kafka /opt/kafka/bin/kafka-topics.sh --create \
  --bootstrap-server localhost:9092 \
  --replication-factor 1 \
  --partitions 3 \
  --topic your-topic-name
```

## Connection Details

- **Kafka Broker (External)**: `localhost:9092`
- **Kafka Broker (Internal)**: `kafka:29092` (for container-to-container communication)
- **Controller Port**: `9093` (internal only, for KRaft controller communication)

### For Applications

- **Local applications**: Use `localhost:9092`
- **Docker containers in same network**: Use `kafka:29092`

## Architecture

The setup uses **KRaft mode** (Kafka Raft), which means:
- **No Zookeeper required**: Kafka manages its own metadata using the Raft consensus algorithm
- **Kafka Broker/Controller**: Single node running as both broker and controller (node.id=1)
- **Kafka Init**: A one-time initialization container that creates the sample topic
- **Simpler setup**: Fewer moving parts, faster startup, better performance
- **Persistent storage**: Data is stored in a Docker volume (`kafka-data`)

### Configuration Files

- **`docker-compose.yml`**: Defines the Kafka and initialization services
- **`server.properties`**: KRaft mode configuration file mounted into the container
- **`init-topic.sh`**: Optional manual script to create topics (automatic via docker-compose)

### Services

1. **kafka**: Main Kafka broker running in KRaft mode
   - Ports: `9092` (client), `9093` (controller)
   - Automatically formats storage on first run
   - Health check ensures readiness before init container starts

2. **kafka-init**: Initialization container
   - Waits for Kafka to be ready
   - Creates `sample-topic` with 3 partitions
   - Exits after successful topic creation

## Troubleshooting

### Check Kafka logs
```bash
docker-compose logs kafka
```

### Check initialization logs
```bash
docker-compose logs kafka-init
```

### View all logs
```bash
docker-compose logs
```

### Restart everything (clean slate)
```bash
docker-compose down -v
docker-compose up -d
```
**Note**: The `-v` flag removes volumes, so all data will be lost.

### Check if Kafka is running
```bash
docker ps
```

### Check Kafka health
```bash
docker exec kafka /opt/kafka/bin/kafka-broker-api-versions.sh --bootstrap-server localhost:9092
```

### Common Issues

1. **Container fails to start**: Check if ports 9092 and 9093 are already in use
2. **Topic not created**: Check `kafka-init` logs - it may need Kafka to be fully ready
3. **Storage format errors**: Remove the volume and restart: `docker-compose down -v && docker-compose up -d`
