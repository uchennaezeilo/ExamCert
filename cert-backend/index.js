require('dotenv').config();


const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;

app.use(cors());
app.use(express.json());
const pool = require('./db'); // Ensure we can use the pool for the reset password route if needed, or just for consistency

// Routes
const authRoutes = require('./routes/auth');
app.use('/api/auth', authRoutes);

const examRoutes = require('./routes/exams');
app.use('/api/exams', examRoutes);

const certificationRoutes = require('./routes/certifications');
app.use('/api/certifications', certificationRoutes);

const questionRoutes = require('./routes/questions');
app.use('/api/questions', questionRoutes);

app.get('/', (req, res) => {
  res.send('Cert Exam API is running 🚀');
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
