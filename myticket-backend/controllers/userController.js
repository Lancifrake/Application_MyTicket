import { db } from "../config/db.js";
import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";

// Récupérer le profil de l'utilisateur connecté
export const getUserProfile = async (req, res) => {
  try {
    const userId = req.user.id; // Récupération de l'ID utilisateur depuis le token
    const [rows] = await db.query(
      "SELECT username, email, numDeTelephone FROM personne WHERE id = ?",
      [userId]
    );
    const user = rows[0];

    if (!user) {
      return res.status(404).json({ message: "Utilisateur non trouvé" });
    }

    res.json(user);
  } catch (error) {
    console.error("Erreur lors de la récupération du profil :", error);
    res.status(500).json({ message: "Erreur serveur" });
  }
};

// Mettre à jour le profil utilisateur
export const updateUserProfile = async (req, res) => {
  try {
    const userId = req.user.id;
    const { username, email, numDeTelephone, motDePasse } = req.body;

    if (!username || !email || !numDeTelephone) {
      return res
        .status(400)
        .json({ message: "Tous les champs sont obligatoires." });
    }

    let query =
      "UPDATE personne SET username = ?, email = ?, numDeTelephone = ?";
    const values = [username, email, numDeTelephone];

    if (motDePasse) {
      // Si le champ motDePasse est présent
      const hashedPassword = await bcrypt.hash(motDePasse, 10);
      query += ", motDePasse = ?";
      values.push(hashedPassword);
    }

    query += " WHERE id = ?";
    values.push(userId);

    await db.query(query, values);
    res.json({ message: "Profil mis à jour avec succès." });
  } catch (error) {
    console.error("Erreur lors de la mise à jour du profil :", error);
    res.status(500).json({ message: "Erreur serveur" });
  }
};

export const getUserById = async (req, res) => {
  const { userId } = req.params;

  if (!userId) {
    return res
      .status(400)
      .json({ message: "L'ID de l'utilisateur est requis." });
  }

  try {
    const [user] = await db.query(
      "SELECT id, email, numDeTelephone AS phoneNumber, walletAddress FROM personne WHERE id = ?",
      [userId]
    );

    if (user.length === 0) {
      return res.status(404).json({ message: "Utilisateur non trouvé." });
    }

    res.status(200).json(user[0]); // Retourne les infos de l'utilisateur
  } catch (error) {
    console.error(
      " Erreur lors de la récupération de l'utilisateur :",
      error.message
    );
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const getUserTickets = async (req, res) => {
  const { userId } = req.params;

  if (!userId) {
    return res
      .status(400)
      .json({ message: "L'ID de l'utilisateur est requis." });
  }

  try {
    console.log(`📡 Récupération des tickets de l'utilisateur ${userId}...`);

    const [tickets] = await db.query(
      `SELECT t.id AS ticketId, t.ticket_name, t.type, t.stockageNFT, t.imageURL, 
              e.nom AS eventName, e.date, e.lieu, m.id AS marketId 
       FROM ticket t 
       INNER JOIN evenement e ON t.evenementId = e.idEvenement
       LEFT JOIN marketplace m ON t.id = m.ticketId
       WHERE t.proprietaireId = ? AND (m.id IS NULL OR m.statut != 'en vente')`,
      [userId]
    );

    res.status(200).json({ tickets });
  } catch (error) {
    console.error(
      "Erreur lors de la récupération des tickets :",
      error.message
    );
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};
