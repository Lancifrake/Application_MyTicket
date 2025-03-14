import { db } from '../config/db.js';
import jwt from 'jsonwebtoken';
import bcrypt from 'bcryptjs';
import { updateUserProfile } from "./userController.js";
import { Keypair } from '@solana/web3.js'; // Import pour générer le wallet Solana

export const register = async (req, res) => {
    const { username, email, motDePasse, numDeTelephone } = req.body;

    if (!username || !email || !motDePasse || !numDeTelephone) {
        return res.status(400).json({ message: 'Tous les champs sont obligatoires' });
    }

    try {
        // Hash du mot de passe
        const hashedPassword = await bcrypt.hash(motDePasse, 10);
        const role = 'utilisateur';

        // 🔥 Génération d'un wallet Solana pour l'utilisateur
        const keypair = Keypair.generate();
        const walletAddress = keypair.publicKey.toString();
        const privateKey = Buffer.from(keypair.secretKey).toString('hex'); // ⚠️ À sécuriser dans un gestionnaire sécurisé

        // Enregistrement de l'utilisateur avec l'adresse de son wallet
        const [result] = await db.query(
            'INSERT INTO personne (username, email, motDePasse, numDeTelephone, role, walletAddress, privateKey) VALUES (?, ?, ?, ?, ?, ?, ?)',
            [username, email, hashedPassword, numDeTelephone, role, walletAddress, privateKey]
        );

        res.status(201).json({
            message: 'Utilisateur créé avec succès',
            userId: result.insertId,
            walletAddress: walletAddress
        });
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

        res.json({ message: 'Connexion réussie', token, role: user.role, id: user.id });
    } catch (error) {
        console.error('Erreur lors de la connexion :', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};
