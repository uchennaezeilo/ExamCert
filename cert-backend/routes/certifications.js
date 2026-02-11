const express = require('express');
const router = express.Router();
const pool = require('../db');
const auth = require('../middleware/auth');

// Get all certifications
router.get('/', async (req, res) => {
  try {
    // Return a canonical `id` field to avoid client-side key guessing
    const result = await pool.query('SELECT certification_id AS id, name FROM certifications ORDER BY certification_id ASC');
    res.json(result.rows);
  } catch (err) {
    console.error('Error fetching certifications:', err);
    res.status(500).json({ error: 'Failed to fetch certifications' });
  }
});

// Get questions for a specific certification
router.get('/:id/questions', auth, async (req, res) => {
  console.log('Headers:', req.headers);
  console.log('Params:', req.params);
  
  try {
    const rawId = req.params.id;
    const certificationId = Number(rawId);

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
    const result = await pool.query(sql, [certificationId]);
    res.json(result.rows);
  } catch (err) {
    console.error('❌ SQL error:', err);
    res.status(500).json({ error: 'Failed to fetch questions' });
  }
});

module.exports = router;