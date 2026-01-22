const express = require('express');
const app = express();
const path = require('path');
const fs = require('fs');

// SETUP //
const vault_addr = process.env.VAULT_ADDR;
const vault_root_token = process.env.VAULT_ROOT_TOKEN;  // bootstrap secret
const vault_token = 'openweathermap';  // vault endpoint for secret
let api_key = undefined;  // secret

async function vaultGetSecretKV1(vault_root_token, vault_token) {
    const url = vault_addr + '/'  + 'v1/kv/' + vault_token;
    console.log('fetching secret from ' + url);
    const vault_response = await fetch(url,{
        method: 'GET',
        headers: {'X-VAULT-TOKEN':vault_root_token}
    });

    const raw = await vault_response.json();
    return raw.data.secret;
}

// Hierdoor kan de server je front-end bestand tonen (index.html)
indexfile = path.join(__dirname, 'index.html')
app.get("/", (req, res) => {
    res.status(200).sendFile(indexfile)
});

// info endpoint
app.get('/info', async (req, res) => {
    api_key = await vaultGetSecretKV1(vault_root_token, vault_token);
    const url = `https://api.openweathermap.org/data/2.5/weather?q=Brussels&appid=${api_key}`;
    console.log("fetching external api data from" + url)
    const api_response = await fetch(url);
    const data = await api_response.json();
    res.send(data);
});

// status endpoint
app.get('/status', async (req, res) => {
    const vault_endpoint = 'v1/sys/seal-status';
    console.log('fetching from ' + vault_addr + '/' + vault_endpoint)
    const vault_response = await fetch(vault_addr + '/' + vault_endpoint);
    const raw = await vault_response.json();
    res.send(raw);
});

// vault endpoint
app.get('/vault', async (req, res) => {
    const secret = await vaultGetSecretKV1(vault_root_token, vault_token);
    res.send(secret);
});

// Start server op poort 3000
const port = 3000;
app.listen(port, () => console.log(`Server draait op http://localhost:${port}`));