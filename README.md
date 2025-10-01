# Azure MCP Chat Demo with demo-magic

This repo shows how to deploy a simple **AI assistant app** on **Azure Container Apps** that uses **Azure OpenAI**.  
The demo is scripted using [demo-magic](https://github.com/paxtonhare/demo-magic), a tool for running live shell demos with smooth playback and auto-typing effects.

---

## 🚀 What this demo does

The demo script (`demo.sh`) will:

1. Discover your Azure OpenAI resource (endpoint, keys, deployments).  
2. Build a simple Node.js app container.  
3. Push the image to Azure Container Registry (ACR).  
4. Deploy the app to Azure Container Apps with the proper environment variables.  
5. Print the public URL where the app can be tested.  

This makes it easy to present the end-to-end workflow of going from Azure OpenAI setup → containerized app → deployment.

---

## 📦 Prerequisites

Make sure you have the following installed/configured before running the demo:

- [Azure CLI](https://learn.microsoft.com/cli/azure/install-azure-cli) (≥ 2.77)  
- [Docker](https://docs.docker.com/get-docker/)  
- `jq` for JSON parsing  
- An Azure subscription with **Azure OpenAI** access enabled  
- A Cognitive Services resource of kind `OpenAI` already provisioned  

---

## ▶️ How to run

Clone the repo and execute the script:

```bash
git clone https://github.com/ricmmartins/mcp-chat-demo-magic.git
cd mcp-chat-demo-magic
./demo.sh
```

You should see the demo-magic script simulate the commands step by step, showing the deployment process interactively.

---

## 📚 References

- [demo-magic GitHub Repo](https://github.com/paxtonhare/demo-magic) — official source of the script.  
- [How to Create Terminal Demos with demo-magic](https://martinheinz.dev/blog/94) — excellent blog post by Martin Heinz with tips, tricks, and examples for making great demos.  

These resources will help you understand how the demo-magic tool works and how you can adapt it to your own live demos.

---

## 🛠 Customization

You can customize the demo in several ways:

- **API version**: Update the `API_VERSION` variable in `demo.sh` if Azure introduces a newer API version.  
- **Deployment name**: Edit the query for `DEPLOYMENT_NAME` to target the specific model you want (`gpt-35-turbo`, `gpt-4o-mini`, `gpt-4`, etc.).  
- **Demo style**: You can tune typing speed and prompt appearance in `demo.sh` via `TYPE_SPEED` and `DEMO_PROMPT`.  
- **App logic**: Replace the sample Node.js app with your own application code if you want to demonstrate custom scenarios.  

---

## 📜 License

This project is licensed under the **MIT License**.  
You are free to use, copy, modify, and distribute it with attribution.

---
