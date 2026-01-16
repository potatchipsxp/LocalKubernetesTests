const express = require('express');
const { Pool } = require('pg');
const path = require('path');

const app = express();
const port = 80;

// PostgreSQL connection
const pool = new Pool({
  host: process.env.POSTGRES_HOST || 'db',
  port: 5432,
  user: 'postgres',
  password: 'postgres',
  database: 'postgres'
});

app.use(express.static('public'));

app.get('/', (req, res) => {
  res.sendFile(path.join(__dirname, 'public', 'index.html'));
});

app.get('/votes', async (req, res) => {
  try {
    const result = await pool.query(
      'SELECT vote, COUNT(id) as count FROM votes GROUP BY vote'
    );
    
    const votes = {};
    result.rows.forEach(row => {
      votes[row.vote] = parseInt(row.count);
    });
    
    res.json(votes);
  } catch (err) {
    console.error('Error querying database:', err);
    res.json({});
  }
});

app.get('/health', (req, res) => {
  res.send('healthy');
});

app.listen(port, () => {
  console.log(`Result app listening on port ${port}`);
});
