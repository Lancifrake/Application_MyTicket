import express from 'express';
import { verifyToken, checkRole } from '../middleware/authMiddleware.js';

const router = express.Router();

router.get('/', verifyToken, checkRole(['organisateur', 'admin']), (req, res) => {
    res.json({ message: 'Bienvenue, organisateur !' });
});

export default router;
