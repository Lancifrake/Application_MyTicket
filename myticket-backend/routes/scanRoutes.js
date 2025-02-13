import express from 'express';
import { verifyToken, checkRole } from '../middleware/authMiddleware.js';

const router = express.Router();

router.get('/', verifyToken, checkRole(['scanner', 'admin']), (req, res) => {
    res.json({ message: 'Bienvenue, scanner !' });
});

export default router;
