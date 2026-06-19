const express = require('express');
const mysql = require('mysql2/promise');
const fs = require('fs');

const app = express();
const PORT = process.env.PORT || 8080;
const useDatabase = Boolean(process.env.DB_HOST);
let pool;
let memoryMessages = [];

app.use(express.json());
app.use(express.urlencoded({ extended: false }));

async function initDatabase() {
  if (!useDatabase) {
    console.log('DB_HOST not set. Using in-memory storage.');
    return;
  }

  pool = mysql.createPool({
    host: process.env.DB_HOST,
    port: Number(process.env.DB_PORT || 3306),
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
    database: process.env.DB_NAME,
    waitForConnections: true,
    connectionLimit: 5,
    enableKeepAlive: true,
    ssl: process.env.DB_SSL === 'false' ? undefined : {
      ca: fs.readFileSync('/app/repo/azure-mysql-ca-bundle.pem'),
      rejectUnauthorized: true
    }
  });

  await pool.execute(`
    CREATE TABLE IF NOT EXISTS messages (
      id INT AUTO_INCREMENT PRIMARY KEY,
      name VARCHAR(80) NOT NULL,
      message VARCHAR(500) NOT NULL,
      created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )
  `);

  console.log('Connected to Azure MySQL with TLS verified.');
}

async function listMessages() {
  if (!pool) {
    return memoryMessages.slice(-10).reverse();
  }
  const [rows] = await pool.execute(
    'SELECT id, name, message, created_at FROM messages ORDER BY created_at DESC LIMIT 10'
  );
  return rows;
}

async function createMessage(name, message) {
  if (!pool) {
    const item = {
      id: memoryMessages.length + 1,
      name,
      message,
      created_at: new Date().toISOString()
    };
    memoryMessages.push(item);
    return item;
  }
  const [result] = await pool.execute(
    'INSERT INTO messages (name, message) VALUES (?, ?)',
    [name, message]
  );
  return {
    id: result.insertId,
    name,
    message,
    created_at: new Date().toISOString()
  };
}

function sanitizeInput(value, maxLength) {
  return String(value || '').trim().slice(0, maxLength);
}

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

app.get('/health', (req, res) => {
  res.json({
    status: 'ok',
    storage: pool ? 'mysql' : 'memory'
  });
});

app.get('/', async (req, res, next) => {
  try {
    const messages = await listMessages();

    res.send(`
      <!DOCTYPE html>
      <html>
        <head>
          <title>Azure Lightweight Webapp</title>
          <style>
            body { font-family: Arial; margin: 40px; background: #f5f5f5; color: #222; }
            .container { background: white; padding: 20px; border-radius: 5px; max-width: 680px; }
            h1 { color: #0078d4; }
            p { color: #666; }
            form { display: grid; gap: 10px; margin: 20px 0; }
            input, textarea, button { font: inherit; padding: 10px; }
            textarea { min-height: 90px; resize: vertical; }
            button { background: #0078d4; color: white; border: 0; cursor: pointer; }
            .message { border-top: 1px solid #ddd; padding: 12px 0; }
            .message strong { color: #333; }
            .empty { color: #777; }
          </style>
        </head>
        <body>
          <div class="container">
            <h1>Lightweight Web App</h1>
            <p>Running on Azure Free Tier</p>
            <p><strong>Status:</strong> Healthy</p>
            <p><strong>Storage:</strong> ${pool ? 'Azure MySQL' : 'In-memory local storage'}</p>
            <p><strong>Timestamp:</strong> ${new Date().toISOString()}</p>

            <form method="POST" action="/messages">
              <input name="name" maxlength="80" placeholder="Your name" required />
              <textarea name="message" maxlength="500" placeholder="Write a short message" required></textarea>
              <button type="submit">Save message</button>
            </form>

            <h2>Latest messages</h2>
            ${
              messages.length
                ? messages.map(item => `
                  <div class="message">
                    <strong>${escapeHtml(item.name)}</strong>
                    <p>${escapeHtml(item.message)}</p>
                    <small>${new Date(item.created_at).toISOString()}</small>
                  </div>
                `).join('')
                : '<p class="empty">No messages saved yet.</p>'
            }
          </div>
        </body>
      </html>
    `);
  } catch (err) {
    next(err);
  }
});

app.get('/api/info', (req, res) => {
  res.json({
    app: 'lightweight-webapp',
    storage: pool ? 'mysql' : 'memory',
    timestamp: new Date().toISOString(),
    uptime: process.uptime()
  });
});

app.get('/api/messages', async (req, res, next) => {
  try {
    res.json(await listMessages());
  } catch (err) {
    next(err);
  }
});

app.post('/api/messages', async (req, res, next) => {
  try {
    const name = sanitizeInput(req.body.name, 80);
    const message = sanitizeInput(req.body.message, 500);
    if (!name || !message) {
      return res.status(400).json({ error: 'name and message are required' });
    }
    res.status(201).json(await createMessage(name, message));
  } catch (err) {
    next(err);
  }
});

app.post('/messages', async (req, res, next) => {
  try {
    const name = sanitizeInput(req.body.name, 80);
    const message = sanitizeInput(req.body.message, 500);
    if (!name || !message) {
      return res.status(400).send('name and message are required');
    }
    await createMessage(name, message);
    res.redirect('/');
  } catch (err) {
    next(err);
  }
});

app.use((req, res) => {
  res.status(404).json({ error: 'Not found' });
});

app.use((err, req, res, next) => {
  console.error(err);
  res.status(500).json({ error: 'Internal server error' });
});

// Fail fast: if DB_HOST is set, the app is expected to use MySQL.
// A failed connection means something is genuinely wrong (bad creds,
// firewall, expired cert) and should not be silently masked by falling
// back to in-memory storage — that would make data loss invisible.
initDatabase()
  .then(() => {
    app.listen(PORT, () => {
      console.log(`Server running on port ${PORT}`);
    });
  })
  .catch((err) => {
    console.error('Failed to initialize storage:', err);
    process.exit(1);
  });