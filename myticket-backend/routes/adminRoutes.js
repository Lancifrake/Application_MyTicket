import express from 'express';
import { verifyToken, checkRole } from '../middleware/authMiddleware.js';

const router = express.Router();

router.get('/', verifyToken, checkRole(['admin']), (req, res) => {
    res.json({ message: 'Bienvenue sur la page admin !' });
});

export default router;
