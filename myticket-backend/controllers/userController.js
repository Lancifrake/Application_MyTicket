import { db } from '../config/db.js';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';

// Récupérer le profil de l'utilisateur connecté
export const getUserProfile = async (req, res) => {
    try {
        const userId = req.user.id;  // Récupération de l'ID utilisateur depuis le token
        const [rows] = await db.query('SELECT username, email, numDeTelephone FROM personne WHERE id = ?', [userId]);
        const user = rows[0];

        if (!user) {
            return res.status(404).json({ message: 'Utilisateur non trouvé' });
        }

        res.json(user);
    } catch (error) {
        console.error('Erreur lors de la récupération du profil :', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};

// Mettre à jour le profil utilisateur
export const updateUserProfile = async (req, res) => {
    try {
        const userId = req.user.id;
        const { username, email, numDeTelephone, motDePasse } = req.body;

        if (!username || !email || !numDeTelephone) {
            return res.status(400).json({ message: 'Tous les champs sont obligatoires.' });
        }

        let query = 'UPDATE personne SET username = ?, email = ?, numDeTelephone = ?';
        const values = [username, email, numDeTelephone];

        if (motDePasse) {  // Si le champ motDePasse est présent
            const hashedPassword = await bcrypt.hash(motDePasse, 10);
            query += ', motDePasse = ?';
            values.push(hashedPassword);
        }

        query += ' WHERE id = ?';
        values.push(userId);

        await db.query(query, values);
        res.json({ message: 'Profil mis à jour avec succès.' });
    } catch (error) {
        console.error('Erreur lors de la mise à jour du profil :', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};
