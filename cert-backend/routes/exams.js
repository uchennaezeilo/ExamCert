const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const { Pool } = require('pg');

const pool = new Pool({
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  host: process.env.DB_HOST,
  port: process.env.DB_PORT,
  database: process.env.DB_NAME,
});

// START EXAM
router.post('/start', auth, async (req, res) => {
   // 1. Check if user is authenticated
  if (!req.user) {
    return res.status(401).json({ message: 'User not authenticated' });
  }
  const userId = req.user.userId || req.user.id; 
  
  const { certificationId } = req.body;

  try {
    const result = await pool.query(
      `
      INSERT INTO exam_attempts (user_id, certification_id, started_at, attempt_status)
      VALUES ($1, $2, NOW(), 'IN_PROGRESS')
      RETURNING id
      `,
      [userId, certificationId]
    );

    res.json({ attemptId: result.rows[0].id });
  } catch (err) {
    console.error('Start exam error:', err);
    res.status(500).json({ error: 'Failed to start exam' });
  }
});


// SAVE ANSWER
router.post('/answer', auth, async (req, res) => {
  const { attemptId, questionId, selectedOption } = req.body;

  try {
    await pool.query(
      `
      INSERT INTO exam_answers (attempt_id, question_id, selected_option)
      VALUES ($1, $2, $3)
      ON CONFLICT (attempt_id, question_id)
      DO UPDATE SET selected_option = EXCLUDED.selected_option
      `,
      [attemptId, questionId, selectedOption]
    );

    res.json({ success: true });
  } catch (err) {
    console.error('Save answer error:', err);
    res.status(500).json({ error: 'Failed to save answer' });
  }
});


// FINISH EXAM
router.post('/finish', auth, async (req, res) => {
  const { attemptId } = req.body;

  try {
    const result = await pool.query(
      `
      SELECT ea.selected_option, q.correct_option
      FROM exam_answers ea
      JOIN questions q ON q.id = ea.question_id
      WHERE ea.attempt_id = $1
      `,
      [attemptId]
    );

    let score = 0;
    result.rows.forEach(r => {
      if (r.selected_option === r.correct_option) score++;
    });

    await pool.query(
      `
      UPDATE exam_attempts
      SET
        score = $1,
        finished_at = NOW(),
        attempt_status = 'COMPLETED'
      WHERE id = $2
      `,
      [score, attemptId]
    );

    res.json({ score });
  } catch (err) {
    console.error('Finish exam error:', err);
    res.status(500).json({ error: 'Failed to finish exam' });
  }
});

//RESUME ACTIVE EXAM
router.get('/active', auth, async (req, res) => {
  const userId = req.user.id;

  const attempt = await pool.query(
    `
    SELECT * FROM exam_attempts
    WHERE user_id = $1 AND finished_at IS NULL
    LIMIT 1
    `,
    [userId]
  );

  if (attempt.rows.length === 0) {
    return res.json(null);
  }

  const answers = await pool.query(
    `
    SELECT question_id, selected_option
    FROM exam_answers
    WHERE attempt_id = $1
    `,
    [attempt.rows[0].id]
  );

  res.json({
    attempt: attempt.rows[0],
    answers: answers.rows,
  });
});

//EXAM HISTPORY
router.get('/history', auth, async (req, res) => {
  const userId = req.user.id;

  const result = await pool.query(
    `
    SELECT 
      ea.id,
      c.name,
      ea.score,
      ea.started_at,
      ea.finished_at
    FROM exam_attempts ea
    JOIN certifications c ON c.certification_id = ea.certification_id
    WHERE ea.user_id = $1
    ORDER BY ea.started_at DESC
    `,
    [userId]
  );

  res.json(result.rows);
});


module.exports = router;
