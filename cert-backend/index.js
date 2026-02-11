require('dotenv').config();
console.log('🔐 DB_PASSWORD type:', typeof process.env.DB_PASSWORD);


const express = require('express');
const auth = require('./middleware/auth');
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
const authRoutes = require('./routes/auth');
app.use('/api/auth', authRoutes);

const examRoutes = require('./routes/exams');
app.use('/api/exams', examRoutes);



app.get('/api/questions', async (req, res) => {
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

app.post('/api/questions', async (req, res) => {
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

app.get('/api/certifications', async (req, res) => {
  try {
    // Return a canonical `id` field to avoid client-side key guessing
    const result = await pool.query('SELECT certification_id AS id, name FROM certifications ORDER BY certification_id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching certifications:', err);
    res.status(500).json({ error: 'Failed to fetch certifications' });
  }
});



app.get('/api/certifications/:id/questions', auth, async (req, res) => {
  console.log('Headers:', req.headers);
  console.log('Params:', req.params);
  console.log('Query:', req.query);
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


// Serve a simple HTML page for Password Reset
app.get('/reset-password', (req, res) => {
  res.send(`
    <!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Reset Password</title>
      <style>
        body { font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, Helvetica, Arial, sans-serif; display: flex; justify-content: center; align-items: center; height: 100vh; margin: 0; background-color: #f0f2f5; }
        .card { background: white; padding: 2rem; border-radius: 8px; box-shadow: 0 4px 6px rgba(0,0,0,0.1); width: 100%; max-width: 400px; }
        h2 { margin-top: 0; color: #333; text-align: center; }
        input { width: 100%; padding: 0.75rem; margin-bottom: 1rem; border: 1px solid #ddd; border-radius: 4px; box-sizing: border-box; font-size: 1rem; }
        button { width: 100%; padding: 0.75rem; background-color: #007bff; color: white; border: none; border-radius: 4px; font-size: 1rem; cursor: pointer; transition: background 0.2s; }
        button:hover { background-color: #0056b3; }
        .message { margin-top: 1rem; text-align: center; font-size: 0.9rem; }
        .error { color: #dc3545; }
        .success { color: #28a745; }
      </style>
    </head>
    <body>
      <div class="card">
        <h2>Reset Password</h2>
        <form id="resetForm">
          <input type="password" id="password" placeholder="New Password" required minlength="6">
          <input type="password" id="confirmPassword" placeholder="Confirm New Password" required minlength="6">
          <button type="submit">Set New Password</button>
        </form>
        <div id="message" class="message"></div>
      </div>
      <script>
        const form = document.getElementById('resetForm');
        const messageDiv = document.getElementById('message');
        const urlParams = new URLSearchParams(window.location.search);
        const token = urlParams.get('token');

        if (!token) {
          messageDiv.textContent = 'Invalid link. Token is missing.';
          messageDiv.className = 'message error';
          form.style.display = 'none';
        }

        form.addEventListener('submit', async (e) => {
          e.preventDefault();
          const password = document.getElementById('password').value;
          const confirmPassword = document.getElementById('confirmPassword').value;

          if (password !== confirmPassword) {
            messageDiv.textContent = 'Passwords do not match.';
            messageDiv.className = 'message error';
            return;
          }

          messageDiv.textContent = 'Processing...';
          messageDiv.className = 'message';

          try {
            const response = await fetch('/api/auth/reset-password', {
              method: 'POST',
              headers: { 'Content-Type': 'application/json' },
              body: JSON.stringify({ token, password })
            });
            
            const data = await response.json();
            
            if (response.ok) {
              messageDiv.textContent = 'Success! Your password has been reset.';
              messageDiv.className = 'message success';
              form.style.display = 'none';
            } else {
              messageDiv.textContent = data.message || 'Failed to reset password.';
              messageDiv.className = 'message error';
            }
          } catch (err) {
            console.error(err);
            messageDiv.textContent = 'An error occurred. Please try again later.';
            messageDiv.className = 'message error';
          }
        });
      </script>
    </body>
    </html>
  `);
});


app.listen(port, () => {
  console.log(`Backend running at http://localhost:${port}`);
});
