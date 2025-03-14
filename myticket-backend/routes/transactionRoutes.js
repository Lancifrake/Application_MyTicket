import express from 'express';
import { createTransaction, confirmTransaction } from '../controllers/transactionController.js';

const router = express.Router();

router.post('/create', createTransaction);
router.post('/confirm', confirmTransaction);

export default router;
