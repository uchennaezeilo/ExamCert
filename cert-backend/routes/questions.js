const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// Get questions (optional filter by certificationId)
router.get('/', async (req, res) => {
  try {
    const { certificationId } = req.query;
    let result;
    if (certificationId) {
      result = await pool.query(
        'SELECT * FROM questions WHERE certification_id = $1 ORDER BY id ASC',
        [certificationId]
      );
    } else {
      result = await pool.query('SELECT * FROM questions ORDER BY id ASC');
    }
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching questions:', err);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// Create a new question
router.post('/', auth, async (req, res) => {
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

module.exports = router;