import axios from "axios";
import { db } from "../config/db.js";
import { createTicket } from "../controllers/ticketController.js";
import { Connection, PublicKey } from "@solana/web3.js";
import { programs } from "@metaplex/js";

const SOLANA_RPC_URL = "https://api.devnet.solana.com";

export const initiatePayment = async (req, res) => {
  const { userId, amount, phoneNumber, evenementId, ticketType } = req.body;

  if (!userId || !amount || !phoneNumber || !evenementId || !ticketType) {
    return res
      .status(400)
      .json({ message: "Données incomplètes pour l'achat." });
  }

  try {
    console.log("Démarrage du paiement pour l'achat d'un ticket.");

    // Insérer un nouveau ticket AVANT le paiement
    const [ticketResult] = await db.query(
      "INSERT INTO ticket (proprietaireId, evenementId, type, qrCode) VALUES (?, ?, ?, ?)",
      [userId, evenementId, ticketType, null]
    );
    const ticketId = ticketResult.insertId;

    console.log("Ticket créé avec ID :", ticketId);

    // Initialiser le paiement (exemple sans CinetPay pour l'instant)
    const transactionId = `TICKET-${Date.now()}-${userId}`;
    await db.query(
      "INSERT INTO transaction (userId, montant, ticketId, confirmationTransaction, transactionId) VALUES (?, ?, ?, 'pending', ?)",
      [userId, amount, ticketId, transactionId]
    );

    console.log("Transaction enregistrée :", transactionId);

    res.status(200).json({
      message: "Ticket créé et paiement en attente.",
      ticketId,
      transactionId,
    });
  } catch (error) {
    console.error("Erreur lors de l'achat du ticket :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const mintNFTAfterPayment = async (walletAddress) => {
  if (!walletAddress) {
    throw new Error("Adresse du wallet requise pour le mint.");
  }

  try {
    console.log("Envoi de la requête de mint au microservice WSL...");

    const response = await axios.post("http://localhost:3001/mint", {
      walletAddress,
      candyMachineId: "6xycm31C3d7MoyczBt3Ghtha7XRcrEWPGiJeYsqKvHme",
    });

    console.log("Réponse du microservice :", response.data);
    return response;
  } catch (error) {
    console.error("Erreur lors du minting :", error.message);
    throw new Error("Erreur lors du minting du NFT.");
  }
};

export const storeMintedNFT = async (req, res) => {
  const { walletAddress, mintId, nftImageUrl, transactionId } = req.body;

  if (!walletAddress || !mintId || !transactionId || !nftImageUrl) {
    return res.status(400).json({ message: "Données incomplètes" });
  }

  try {
    console.log(
      " Enregistrement du NFT minté pour la transaction :",
      transactionId
    );

    // Vérifier si la transaction existe
    const [existingTransaction] = await db.query(
      "SELECT * FROM transaction WHERE transactionId = ? AND confirmationTransaction = 'pending'",
      [transactionId]
    );

    if (existingTransaction.length === 0) {
      return res
        .status(404)
        .json({ message: "Transaction non trouvée ou déjà confirmée." });
    }
    console.log(" Données extraites avant mise à jour :", {
      walletAddress,
      mintId,
      nftImageUrl,
      transactionId,
    });
    // Récupérer les infos de la transaction
    const { userId, ticketId } = existingTransaction[0];
    console.log("🎫 Récupération des infos du ticket :", { userId, ticketId });

    // Mise à jour de la transaction
    const [updateResult] = await db.query(
      "UPDATE transaction SET confirmationTransaction = 'confirmed', adresseWallet = ?, mintId = ?, nftImageUrl = ?, updatedAt = NOW() WHERE transactionId = ?",
      [walletAddress, mintId, nftImageUrl, transactionId]
    );
    console.log(" Transaction mise à jour avec succès.", updateResult);

    // APPEL AUTOMATIQUE DE updateTicketAfterMint
    console.log("🔄 Mise à jour du ticket après mint...");
    const response = await axios.post(
      "http://localhost:2000/api/tickets/updateAfterMint",
      {
        ticketId,
        transactionId,
        mintId,
      }
    );
    console.log("🎟️ Ticket mis à jour avec succès :", response.data);

    res.status(200).json({
      message: " NFT enregistré et ticket mis à jour",
      transactionId,
      mintId,
      nftImageUrl,
    });
  } catch (error) {
    console.error(" Erreur lors de l'enregistrement du NFT :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};
