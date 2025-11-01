CSV Server Assignment - Complete Solution
Prerequisites
Docker and Docker Compose installed

Git Bash (on Windows)

All commands should be run from the solution directory

Part I: Basic CSV Server Setup
Step 1: Initial container run (failed - missing input file)
bash
docker run -d --name csvserver infracloudio/csvserver:latest
docker logs csvserver
# Error: error while reading the file "/csvserver/inputdata"
Step 2: Create and run gencsv.sh script
bash
chmod +x gencsv.sh
./gencsv.sh 2 8
# Generated inputFile with 7 entries
gencsv.sh content:

bash
#!/bin/bash

# Check if arguments are provided
if [ $# -ne 2 ]; then
    echo "Usage: $0 <start_index> <end_index>"
    exit 1
fi

start=$1
end=$2

# Remove existing inputFile
rm -f inputFile

# Generate the file
for ((i=start; i<=end; i++)); do
    random=$((RANDOM % 1000))
    echo "$i, $random" >> inputFile
done

echo "Generated inputFile with $((end - start + 1)) entries"
Step 3: Run container with volume mount (Windows path fix)
bash
# For Windows Git Bash, use Windows path format
windows_path=$(pwd -W)
docker run -d --name csvserver -v "${windows_path//\//\\}/inputFile:/csvserver/inputdata" infracloudio/csvserver:latest
Step 4: Find application port
Application listens on port 9300 inside container (determined from standard configuration)

Note: Shell access failed due to Windows/Git Bash compatibility issues

Step 5: Final container run with all configurations
bash
docker run -d --name csvserver -p 9393:9300 -e CSVSERVER_BORDER=Orange -v "$(pwd)/inputFile:/csvserver/inputdata" infracloudio/csvserver:latest
Step 6: Generate output files
bash
curl -o ./part-1-output http://localhost:9393/raw
docker logs csvserver >& part-1-logs
Step 7: Create part-1-cmd file
bash
echo 'docker run -d --name csvserver -p 9393:9300 -e CSVSERVER_BORDER=Orange -v "$(pwd)/inputFile:/csvserver/inputdata" infracloudio/csvserver:latest' > part-1-cmd
Part II: Docker Compose Setup
Step 1: Stop and remove containers
bash
docker stop csvserver
docker rm csvserver
Step 2: Create docker-compose.yaml
yaml
version: '3.8'

services:
  csvserver:
    image: infracloudio/csvserver:latest
    ports:
      - "9393:9300"
    environment:
      - CSVSERVER_BORDER=Orange
    volumes:
      - ./inputFile:/csvserver/inputdata
    env_file:
      - csvserver.env
Step 3: Create csvserver.env
bash
CSVSERVER_BORDER=Orange
Step 4: Test Docker Compose
bash
docker-compose up -d
Step 5: Verify CSV Server
Access at: http://localhost:9393

Part III: Prometheus Integration
Step 1: Update docker-compose.yaml
yaml
version: '3.8'

services:
  csvserver:
    image: infracloudio/csvserver:latest
    ports:
      - "9393:9300"
    environment:
      - CSVSERVER_BORDER=Orange
    volumes:
      - ./inputFile:/csvserver/inputdata
    env_file:
      - csvserver.env
    networks:
      - csvserver-net

  prometheus:
    image: prom/prometheus:v2.45.2
    ports:
      - "9090:9090"
    volumes:
      - ./prometheus.yml:/etc/prometheus/prometheus.yml
    networks:
      - csvserver-net

networks:
  csvserver-net:
    driver: bridge
Step 2: Create prometheus.yml
yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'csvserver'
    static_configs:
      - targets: ['csvserver:9300']
Step 3: Start the full setup
bash
docker-compose down
docker-compose up -d
Step 4: Verify both services
CSV Server: http://localhost:9393

Prometheus: http://localhost:9090

Step 5: Test Prometheus metrics
Go to http://localhost:9090

Type csvserver_records in the query box

Click "Execute"

Switch to "Graph" tab

You should see a straight line at value 7 (representing 7 CSV records)
