import { db } from '../config/db.js';

export const createTransaction = async (req, res) => {
    const { userId, type, montant, ticketId, adresseWallet, transactionId } = req.body;

    if (!userId || !type || !montant || !ticketId || !transactionId) {
        return res.status(400).json({ message: "Données incomplètes" });
    }

    try {
        const [result] = await db.query(
            `INSERT INTO transaction (userId, type, adresseWallet, montant, ticketId, confirmationTransaction, transactionId)
             VALUES (?, ?, ?, ?, ?, 'pending', ?)`,
            [userId, type, adresseWallet || null, montant, ticketId, transactionId]
        );

        res.status(201).json({ message: "Transaction enregistrée", idTransaction: result.insertId });
    } catch (error) {
        console.error("Erreur lors de l'enregistrement de la transaction :", error);
        res.status(500).json({ message: "Erreur serveur" });
    }
};

export const confirmTransaction = async (req, res) => {
    const { transactionId, statut } = req.body;

    if (!transactionId || !statut) {
        return res.status(400).json({ message: "Transaction ID et statut requis" });
    }

    try {
        const [result] = await db.query(
            `UPDATE transaction SET confirmationTransaction = ?, updatedAt = CURRENT_TIMESTAMP WHERE transactionId = ?`,
            [statut, transactionId]
        );

        if (result.affectedRows === 0) {
            return res.status(404).json({ message: "Transaction introuvable" });
        }

        res.status(200).json({ message: "Transaction mise à jour", statut });
    } catch (error) {
        console.error("Erreur lors de la mise à jour de la transaction :", error);
        res.status(500).json({ message: "Erreur serveur" });
    }
};
