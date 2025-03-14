import axios from "axios";
import { db } from "../config/db.js";

export const reportFraudTicket = async (req, res) => {
  const { scannerId, ticketId, reason } = req.body;

  if (!scannerId || !ticketId || !reason) {
    return res
      .status(400)
      .json({ message: "Données incomplètes pour signaler une fraude." });
  }

  try {
    console.log(
      `Signalement d'une fraude pour le ticket ${ticketId} par le scanner ${scannerId}`
    );

    // Vérifier si le ticket existe
    const [ticket] = await db.query("SELECT * FROM ticket WHERE id = ?", [
      ticketId,
    ]);
    if (ticket.length === 0) {
      return res.status(404).json({ message: "Ticket non trouvé." });
    }

    // Insérer le signalement dans la table des fraudes
    await db.query(
      "INSERT INTO fraude_tickets (scannerId, ticketId, reason, date_signalement) VALUES (?, ?, ?, NOW())",
      [scannerId, ticketId, reason]
    );

    res.status(201).json({ message: "Ticket frauduleux signalé avec succès." });
  } catch (error) {
    console.error("Erreur lors du signalement :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};
