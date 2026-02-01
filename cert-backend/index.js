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
    const { certificationId } = req.query;
    let result;
    if (certificationId) {
      // Filter by certification_id (snake_case) when query param is present
      result = await pool.query(
        'SELECT * FROM questions WHERE certification_id = $1 ORDER BY id ASC',
        [certificationId]
      );
    } else {
      result = await pool.query('SELECT * FROM questions ORDER BY id ASC');
    }

    console.log('DB rows:', result.rows);
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
    correct_option,
  } = req.body;

  try {
    const result = await pool.query(
      `INSERT INTO questions 
       (question, option_a, option_b, option_c, option_d, option_e, correct_option)
       VALUES ($1,$2,$3,$4,$5,$6,$7)
       RETURNING *`,
      [question, option_a, option_b, option_c, option_d, option_e, correct_option]
    );

    res.status(201).json(result.rows[0]);
  } catch (err) {
    console.error('Error inserting question:', err);
    res.status(500).json({ error: 'Failed to insert question' });
  }
});

app.get('/certifications', async (req, res) => {
  try {
    // Return a canonical `id` field to avoid client-side key guessing
    const result = await pool.query('SELECT certification_id AS id, name FROM certifications ORDER BY certification_id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching certifications:', err);
    res.status(500).json({ error: 'Failed to fetch certifications' });
  }
});


app.get('/certifications/:id/questions', async (req, res) => {
  try {
    const rawId = req.params.id;
    const certificationId = Number(rawId);

    console.log('➡️ Raw certification id:', rawId);
    console.log('➡️ Parsed certification id:', certificationId);

    const sql = `
      SELECT 
        id,
        question,
        option_a,
        option_b,
        option_c,
        option_d,
        option_e,
        correct_option
      FROM questions
      WHERE certification_id = $1
      ORDER BY id ASC
    `;

    console.log('🧾 SQL:', sql.trim());
    console.log('🧾 SQL params:', [certificationId]);

    const result = await pool.query(sql, [certificationId]);
    res.json(result.rows);
    console.log('DB rows:', result.rows);

  } catch (err) {
    console.error('❌ SQL error:', err);
    res.status(500).json({ error: 'Failed to fetch questions' });
  }
});




app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`);
});
