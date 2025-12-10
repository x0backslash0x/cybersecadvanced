<img src="../info/op5_vault-demo.png" />

# Thread model
<img src="../info/op5_threat-model_v2.drawio.png" /><br/>

<img src="../info/op5_threat-model_v3.drawio.png" />


# Gebruik
* node.js omgeving installeren (`npm install`)
* vault opstarten (`vault server -dev -dev-root-token-id root`)
* nieuwe secrets engine aanmaken (`vault secrets enable --version=1 kv`)
* API key oplaan in vault (`vault kv put kv/openweathermap secret=`)
* omgevings variabelen instellen voor communicatie met vault
```bash
export VAULT_ADDR=http://127.0.0.1:8200
export VAULT_ROOT_TOKEN=root
```
* server starten (`node server.js`)