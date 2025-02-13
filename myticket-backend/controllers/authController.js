import { db } from '../config/db.js';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

export const register = async (req, res) => {
    const { username, email, motDePasse, numDeTelephone } = req.body;

    if (!username || !email || !motDePasse || !numDeTelephone) {
        return res.status(400).json({ message: 'Tous les champs sont obligatoires' });
    }

    try {
        const hashedPassword = await bcrypt.hash(motDePasse, 10);
        const role = 'utilisateur';
        const [result] = await db.query(
            'INSERT INTO personne (username, email, motDePasse, numDeTelephone, role) VALUES (?, ?, ?, ?, ?)',
            [username, email, hashedPassword, numDeTelephone, role]
        );

        res.status(201).json({ message: 'Utilisateur créé avec succès', userId: result.insertId });
    } catch (error) {
        console.error('Erreur lors de la création de l’utilisateur :', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};
export const login = async (req, res) => {
    const { email, motDePasse } = req.body;

    if (!email || !motDePasse) {
        return res.status(400).json({ message: 'Email et mot de passe requis' });
    }

    try {
        const [rows] = await db.query('SELECT * FROM personne WHERE email = ?', [email]);
        const user = rows[0];

        if (!user) return res.status(404).json({ message: 'Utilisateur non trouvé' });

        const isPasswordValid = await bcrypt.compare(motDePasse, user.motDePasse);
        if (!isPasswordValid) return res.status(401).json({ message: 'Mot de passe incorrect' });

        const token = jwt.sign(
            { id: user.id, email: user.email, username: user.username, numDeTelephone: user.numDeTelephone, role: user.role },
            process.env.JWT_SECRET,
            { expiresIn: '1h' }
        );

        res.json({ message: 'Connexion réussie', token, role: user.role });
    } catch (error) {
        console.error('Erreur lors de la connexion :', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};
