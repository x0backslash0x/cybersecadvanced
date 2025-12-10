const express = require('express');
const app = express();
const path = require('path');
const fs = require('fs');

secret = path.join(__dirname, 'secret')

// Hierdoor kan de server je front-end bestand tonen (index.html)
indexfile = path.join(__dirname, 'index.html')
app.get("/", (req, res) => {
    res.status(200).sendFile(indexfile)
});

// info endpoint
app.get('/info', async (req, res) => {
    const api_key = fs.readFileSync(secret, 'utf-8');
    const api_response = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=Brussels&appid=${api_key}`)
    const data = await api_response.json();
    res.send(data);
});

// status endpoint
app.get('/status', async (req, res) => {
    const vault_addr = process.env.VAULT_ADDR;
    const vault_endpoint = 'v1/sys/seal-status';
    console.log('fetching from ' + vault_addr + '/' + vault_endpoint)
    const vault_response = await fetch(vault_addr + '/' + vault_endpoint);
    const data = await vault_response.json();
    res.send(data);
});

// vault endpoint
app.get('/vault', async (req, res) => {
    const vault_root_token = process.env.VAULT_ROOT_TOKEN;
    const vault_token = 'openweathermap';
    const vault_key = 'secret';
    const vault_addr = process.env.VAULT_ADDR;
    const vault_endpoint = 'v1/kv/';
    console.log('fetching from ' + vault_addr + '/'  + vault_endpoint)
    const vault_response = await fetch(vault_addr + '/' + vault_endpoint + vault_token,{
        method: 'GET',
        headers: {'X-VAULT-TOKEN':vault_root_token}
    });
    const raw = await vault_response.json();
    const data = raw.data;
    res.send(data);
});

// Start server op poort 3000
const port = 3000;
app.listen(port, () => console.log(`Server draait op http://localhost:${port}`));