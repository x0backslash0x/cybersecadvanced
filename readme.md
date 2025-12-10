Repository voor OLOD Cyber Security Advanced
Electronica/ICT - IT & Cybersecurity en Cloud 2025 - 2026
Patrick Lanove

# Opdracht 1
## Threat model
<img src="info/threat-model-draft2.drawio.png" alt="threat model">

*dit model is nog in opbouw en is nog geen volledige weergave*

## Overzicht schema
<img src="info/CybersecAdvanced_opdracht1-schema-uit-les.jpg" alt="schema uit de les">

## Gebruik
**instellingen voor de SPA**
SPA/settings.js
```javascript
import { Log, UserManager} from "oidc-client-ts";

Log.setLogger(console);
Log.setLevel(Log.INFO);

const url = window.location.origin + "";

export const settings = {
    authority: "<your authority>", // https://opa-poc-patrick.eu.auth0.com
    client_id: "<your clientid>", // vLW5tLBAnQ7X261jYY5oGUfsGhUZiyYr
    redirect_uri: url + "/callback.html",
    post_logout_redirect_uri: url + "/index.html",
    response_type: "code",
    scope: "openid email roles",

    response_mode: "query",

    filterProtocolClaims: true,
    extraQueryParams: {
        audience: "<your audience>", // bar-auth0-api
    },
    api_bar_uri: "http://localhost:5172/api/bar",
    api_manageBar_uri: "http://localhost:5172/api/managebar"
};

export {
    Log,
    UserManager
};
```

**instellingen voor de API**
API/appsettings.json
```json
{
  "Logging": {
    "LogLevel": {
      "Default": "Information",
      "Microsoft.AspNetCore": "Warning"
    }
  },
  "AllowedHosts": "*",
  "Jwt": {
    "Authority": "<your authority>", // https://opa-poc-patrick.eu.auth0.com
    "Audience": "<your audience>" // bar-auth0-api
  },
  "Cors": {
    "Origin": "http://localhost:3000"
  }
}
```

**Build and deploy van de services**
```
docker-compose -f docker-compose.yml build
docker-compose -f docker-compose.yml up
```

De SPA zal bereikbaar zijn via localhost:3000

# Opdracht5
<img src="info/op5_vault-demo.png" />

# Thread model
<img src="info/op5_threat-model_v1.drawio.png" /><br/>

<img src="info/op5_threat-model_v2.drawio.png" />


## Gebruik
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
