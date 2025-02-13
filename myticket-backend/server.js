// server.js
import express from 'express';
import dotenv from 'dotenv';
import cors from 'cors';
import authRoutes from './routes/authRoutes.js';
import { db } from './config/db.js';
import userRoutes from './routes/userRoutes.js';
import scanRoutes from './routes/scanRoutes.js';
import adminRoutes from './routes/adminRoutes.js';
import orgRoutes from './routes/orgRoutes.js';
import eventRoutes from './routes/eventRoutes.js';

dotenv.config();
const app = express();

app.use(express.json());
app.use(cors({origin: '*'}));

// Route de test
app.get('/test-db', async (req, res) => {
    try {
        const [rows] = await db.query('SELECT 1 + 1 AS solution');
        res.json({ message: `La solution est ${rows[0].solution}` });
    } catch (error) {
        console.error('Erreur de connexion à la base de données :', error);
        res.status(500).json({ message: 'Erreur de connexion à la base de données' });
    }
});

// Routes
app.use('/api/auth', authRoutes);
app.use('/api/users', userRoutes);
app.use('/api/scanners', scanRoutes);
app.use('/api/admins', adminRoutes);
app.use('/api/organisateurs', orgRoutes);
app.use('/api/events', eventRoutes);

const PORT = process.env.PORT || 2000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
