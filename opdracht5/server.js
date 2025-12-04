const express = require('express');
const app = express();
const path = require('path');

// Hierdoor kan de server je front-end bestand tonen (index.html)
indexfile = path.join(__dirname, 'index.html')
app.get("/", (req, res) => {
    res.status(200).sendFile(indexfile)
});

// info endpoint
app.get('/info', async (req, res) => {
    const api_key = "9b2aba3b52f96d0872c93f0370433ded";
    const api_response = await fetch(`https://api.openweathermap.org/data/2.5/weather?q=Brussels&appid=${api_key}`)
    const data = await api_response.json();
    res.send(data);
});

// Start server op poort 3000
const port = 3000;
app.listen(port, () => console.log(`Server draait op http://localhost:${port}`));