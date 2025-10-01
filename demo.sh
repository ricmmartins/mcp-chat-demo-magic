#!/bin/bash

# Load the demo-magic script
source demo-magic.sh

TYPE_SPEED=100
DEMO_PROMPT="${GREEN}➜ ${CYAN}\W ${COLOR_RESET}"

clear

# ==============================
# Step 1: Clone and enter repo
# ==============================
echo "Cloning the repo and navigating..."
pe "git clone https://github.com/passadis/mslearn-mcp-chat.git"
pe "cd mslearn-mcp-chat"

# ==============================
# Step 2: Discover Azure OpenAI Config
# ==============================

# Get Resource Group and AOAI Resource Name
pe "RESOURCE_GROUP=\$(az cognitiveservices account list \
  --query \"[?kind=='OpenAI'].resourceGroup\" \
  --output tsv | head -n1)"

pe "AOAI_RESOURCE_NAME=\$(az cognitiveservices account list \
  --query \"[?kind=='OpenAI'].name\" \
  --output tsv | head -n1)"

# Get Endpoint (2025-06-01)
pe "AOAI_ENDPOINT=\$(az rest \
  --method get \
  --url \"https://management.azure.com/subscriptions/\$(az account show --query id -o tsv)/resourceGroups/\$RESOURCE_GROUP/providers/Microsoft.CognitiveServices/accounts/\$AOAI_RESOURCE_NAME?api-version=2025-06-01\" \
  --query \"properties.endpoint\" -o tsv)"

# Get Key (2025-06-01)
pe "AOAI_KEY=\$(az rest \
  --method post \
  --url \"https://management.azure.com/subscriptions/\$(az account show --query id -o tsv)/resourceGroups/\$RESOURCE_GROUP/providers/Microsoft.CognitiveServices/accounts/\$AOAI_RESOURCE_NAME/listKeys?api-version=2025-06-01\" \
  --query \"key1\" -o tsv)"

# Get Deployment Name (first deployment in value[])
pe "DEPLOYMENT_NAME=\$(az rest \
  --method get \
  --url \"https://management.azure.com/subscriptions/\$(az account show --query id -o tsv)/resourceGroups/\$RESOURCE_GROUP/providers/Microsoft.CognitiveServices/accounts/\$AOAI_RESOURCE_NAME/deployments?api-version=2025-06-01\" \
  --query \"value[0].name\" -o tsv)"

# ==============================
# Step 3: Write .env.local
# ==============================
pe "echo 'AZURE_OPENAI_KEY=$AOAI_KEY' > .env.local"
pe "echo 'AZURE_OPENAI_ENDPOINT=$AOAI_ENDPOINT' >> .env.local"
pe "echo 'AZURE_OPENAI_DEPLOYMENT_NAME=$DEPLOYMENT_NAME' >> .env.local"

# ==============================
# Step 4: Export env vars
# ==============================
pe "sed 's/^/export /' .env.local > .env.exported"
pe "source .env.exported"

# ==============================
# Step 5: Create Azure Infra
# ==============================
pe "az group create --name rg-mcp-chat --location eastus"
pe "az acr create --name acrmcpchat --resource-group rg-mcp-chat --sku Basic --admin-enabled true"

# ==============================
# Step 6: Create Dockerfile
# ==============================
pe "echo 'FROM node:20' > Dockerfile"
pe "echo 'WORKDIR /app' >> Dockerfile"
pe "echo 'COPY . .' >> Dockerfile"
pe "echo 'RUN npm install && npm run build' >> Dockerfile"
pe "echo 'EXPOSE 3000' >> Dockerfile"
pe "echo 'CMD [\"npm\", \"start\"]' >> Dockerfile"

# ==============================
# Step 7: Build & Push Docker Image
# ==============================
pe "docker build -t acrmcpchat.azurecr.io/mcp-chat:latest ."
pe "az acr login --name acrmcpchat"
pe "docker push acrmcpchat.azurecr.io/mcp-chat:latest"

# ==============================
# Step 8: Deploy to Azure Container Apps
# ==============================
pe "az containerapp env create --name env-mcp-chat --resource-group rg-mcp-chat --location eastus"

pe "az containerapp create --name mcp-chat-app \
  --resource-group rg-mcp-chat \
  --environment env-mcp-chat \
  --image acrmcpchat.azurecr.io/mcp-chat:latest \
  --registry-server acrmcpchat.azurecr.io \
  --cpu 1.0 \
  --memory 2.0Gi \
  --target-port 3000 \
  --ingress external \
  --env-vars AZURE_OPENAI_KEY=$AZURE_OPENAI_KEY AZURE_OPENAI_ENDPOINT=$AOAI_ENDPOINT AZURE_OPENAI_DEPLOYMENT_NAME=$DEPLOYMENT_NAME"

# ==============================
# Step 9: Get URL
# ==============================
pe "az containerapp show --name mcp-chat-app --resource-group rg-mcp-chat --query properties.configuration.ingress.fqdn --output tsv"

echo "🎉 Demo complete! Your AI assistant is deployed."
