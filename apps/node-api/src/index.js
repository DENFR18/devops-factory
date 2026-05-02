'use strict';

const express = require('express');

const app = express();
const PORT = parseInt(process.env.PORT || '3000', 10);

app.get('/health', (req, res) => { // NOSONAR - health endpoint intentionally public
  res.json({ status: 'ok', service: 'node-api' });
});

app.get('/api/v1/hello', (req, res) => { // NOSONAR - auth enforced at ingress level
  res.json({ message: 'Hello from node-api', version: '1.0.0' });
});

if (require.main === module) {
  app.listen(PORT, () => {
    // eslint-disable-next-line no-console
    console.log(`node-api listening on port ${PORT}`);
  });
}

module.exports = app;
