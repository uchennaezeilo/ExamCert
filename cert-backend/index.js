require('dotenv').config();
const express = require('express');
const { Pool } = require('pg');
const cors = require('cors');

const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());

// PostgreSQL connection
const pool = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
});

// Routes
app.get('/questions', async (req, res) => {
  try {
    const result = await pool.query('SELECT * FROM questions ORDER BY id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching questions:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});


app.get('/', (req, res) => {
  res.send('Cert Exam API is running 🚀');
});

app.post('/questions', async (req, res) => {
  const {
    question,
    option_a,
    option_b,
    option_c,
    option_d,
    option_e,
    correct_index,
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO questions 
       (question, option_a, option_b, option_c, option_d, option_e, correct_index)
       VALUES ($1,$2,$3,$4,$5,$6,$7)
       RETURNING *`,
      [question, option_a, option_b, option_c, option_d, option_e, correct_index]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error inserting question:', err);
    res.status(500).json({ error: 'Failed to insert question' });
  }
});


app.listen(port, () => {
  console.log(`✅ Backend running at http://localhost:${port}`);
});
