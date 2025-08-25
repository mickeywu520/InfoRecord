# RAGflow

# Build arm64 docker image
## 1. Clone the git project of RAGflow
```
git clone https://github.com/infiniflow/ragflow.git
cd ragflow 
```
## 2. Build the dependency image first
```
sudo docker build -f Dockerfile.deps -t infiniflow/ragflow_deps .
```
## 3. Build the main RAGFlow image
```
sudo docker build --build-arg ARCH=arm64 -f Dockerfile -t infiniflow/ragflow:arm64 .
```
## 4. Open the .env file and verify the settings. You need to ensure the RAGFLOW_IMAGE variable points to the image you just built.
```
cd ragflow/docker
RAGFLOW_IMAGE=infiniflow/ragflow:arm64
```
## 5. Launch the Service
```
sudo docker compose -f docker-compose.yml up -d
```

## Check the container log 
```
sudo docker logs -f ragflow-server
```

## If encounter the connection refused by ollama base url, please add the environment variable to bind to all interfaces
## in the editor that opens, add the following lines under the [Service] section
```
cd /etc/systemd/system
sudo gedit ollama.service

[Service]
Environment="OLLAMA_HOST=0.0.0.0:11434"
```

## Reload systemd and restart the Ollama service
```
sudo systemctl daemon-reload
sudo systemctl restart ollama
```

## Verify the changes:
```
sudo netstat -tuln | grep 11434
```

## Output should now show:
```
tcp6 0 0 :::11434 :::* LISTEN
```

# Reference
## 1. https://github.com/infiniflow/ragflow
## 2. https://ragflow.io/docs/dev/category/developers
## 3. https://github.com/infiniflow/ragflow/issues/7715
## 4. https://github.com/infiniflow/ragflow/issues/531

