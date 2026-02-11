const express = require('express');
const router = express.Router();
const auth = require('../middleware/auth');
const pool = require('../db');

// START EXAM
/* router.post('/start', auth, async (req, res) => {
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
*/

router.post('/start', auth, async (req, res) => {
  const userId = req.user.userId;
  const { certificationId } = req.body;

  try {
    // 1️⃣ Check for active exam
    const existing = await pool.query(
      `
      SELECT id FROM exam_attempts
      WHERE user_id = $1
        AND certification_id = $2
        AND attempt_status = 'IN_PROGRESS'
      LIMIT 1
      `,
      [userId, certificationId]
    );

    if (existing.rows.length > 0) {
      return res.json({ attemptId: existing.rows[0].id, resumed: true });
    }

    // 2️⃣ Create new attempt
    const result = await pool.query(
      `
      INSERT INTO exam_attempts
        (user_id, certification_id, started_at, attempt_status, current_question)
      VALUES
        ($1, $2, NOW(), 'IN_PROGRESS', 0)
      RETURNING id
      `,
      [userId, certificationId]
    );

    res.json({ attemptId: result.rows[0].id, resumed: false });

  } catch (err) {
    console.error('Start exam error:', err);
    res.status(500).json({ error: 'Failed to start exam' });
  }
});


// SAVE ANSWER
router.post('/answer', auth, async (req, res) => {
  const { attemptId, questionId, selectedOption, currentQuestion  } = req.body;

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

    

    await pool.query(
      `
      UPDATE exam_attempts
      SET current_question = $1
      WHERE id = $2
      `,
      [currentQuestion, attemptId]
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
  const userId = req.user.userId;

  const attempt = await pool.query(
    `
    SELECT * FROM exam_attempts
    WHERE user_id = $1 AND attempt_status = 'IN_PROGRESS'
    ORDER BY started_at DESC
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
    answers: answers.rows
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


// EXAM REVIEW (Get details of a finished exam)
router.get('/:id/review', auth, async (req, res) => {
  const userId = req.user.userId;
  const attemptId = req.params.id;

  try {
    // 1. Verify attempt belongs to user
    const attemptCheck = await pool.query(
      'SELECT user_id FROM exam_attempts WHERE id = $1',
      [attemptId]
    );

    if (attemptCheck.rows.length === 0) {
      return res.status(404).json({ message: 'Attempt not found' });
    }

    if (attemptCheck.rows[0].user_id !== userId) {
      return res.status(403).json({ message: 'Unauthorized' });
    }

    // 2. Fetch questions with user answers and correct answers
    const result = await pool.query(
      `
      SELECT 
        q.id, 
        q.question, 
        q.option_a, 
        q.option_b, 
        q.option_c, 
        q.option_d, 
        q.option_e, 
        q.correct_option,
        ea.selected_option
      FROM exam_answers ea
      JOIN questions q ON ea.question_id = q.id
      WHERE ea.attempt_id = $1
      ORDER BY q.id ASC
      `,
      [attemptId]
    );

    res.json(result.rows);
  } catch (err) {
    console.error('Exam review error:', err);
    res.status(500).json({ error: 'Failed to fetch exam review' });
  }
});

module.exports = router;
