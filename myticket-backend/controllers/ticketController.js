import { db } from "../config/db.js";
import axios from "axios";
import { createUmi } from "@metaplex-foundation/umi-bundle-defaults";
import { fetchDigitalAsset } from "@metaplex-foundation/mpl-token-metadata";
import { PublicKey } from "@solana/web3.js";

const umi = createUmi("https://api.devnet.solana.com");
async function fetchMetadataUri(mintId) {
  try {
    console.log(
      ` Récupération de l'URI des métadonnées pour le NFT : ${mintId}`
    );
    const mintAddress = new PublicKey(mintId);
    const asset = await fetchDigitalAsset(umi, mintAddress);
    return asset.metadata.uri;
  } catch (error) {
    console.error(
      " Impossible de récupérer les métadonnées depuis Solana :",
      error.message
    );
    return null;
  }
}

export const getUserTickets = async (req, res) => {
  const { userId } = req.params;

  try {
    const [tickets] = await db.query(
      `SELECT 
        t.id, 
        t.ticket_name, 
        t.type, 
        t.stockageNFT, 
        t.imageURL,
        e.nom AS evenementNom, 
        e.lieu, 
        e.date
      FROM ticket t
      INNER JOIN evenement e ON t.evenementId = e.idEvenement
      WHERE t.proprietaireId = ?`,
      [userId]
    );

    if (tickets.length === 0) {
      return res.status(200).json([]); // Retourne une liste vide au lieu d'un objet
    }

    res.status(200).json(tickets); // Retourne une liste contenant les infos de l'événement
  } catch (error) {
    console.error(
      "Erreur lors de la récupération des tickets :",
      error.message
    );
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const createTicket = async (userId, evenementId) => {
  try {
    console.log(" Création d'un ticket pour l'achat.");
    const [ticketResult] = await db.query(
      "INSERT INTO ticket (proprietaireId, evenementId, type, qrCode) VALUES (?, ?, ?, ?)",
      [userId, evenementId, "Standard", null]
    );
    console.log(" Ticket créé avec ID :", ticketResult.insertId);
    return ticketResult.insertId;
  } catch (error) {
    console.error(" Erreur lors de la création du ticket :", error.message);
  }
};

export const updateTicketAfterMint = async (req, res) => {
  const { ticketId, transactionId, mintId } = req.body;

  if (!ticketId || !transactionId || !mintId) {
    return res
      .status(400)
      .json({ message: "Données incomplètes pour la mise à jour du ticket" });
  }

  try {
    console.log(" Récupération des informations du ticket pour :", {
      ticketId,
      transactionId,
      mintId,
    });

    //  Vérifier si la transaction existe et récupérer `proprietaireId`
    const [existingTransaction] = await db.query(
      "SELECT userId FROM transaction WHERE transactionId = ?",
      [transactionId]
    );

    if (existingTransaction.length === 0) {
      return res.status(404).json({
        message:
          "Transaction non trouvée, impossible de récupérer proprietaireId",
      });
    }

    const proprietaireId = existingTransaction[0].userId;
    console.log(" Proprietaire ID récupéré :", proprietaireId);

    //  Récupérer l'URL des métadonnées depuis Solana
    const metadataUri = await fetchMetadataUri(mintId);

    if (!metadataUri) {
      return res.status(500).json({
        message: "Impossible de récupérer l'URI des métadonnées depuis Solana.",
      });
    }

    console.log(" Téléchargement des métadonnées depuis :", metadataUri);
    const metadataResponse = await axios.get(metadataUri);
    const metadata = metadataResponse.data;

    console.log(" Métadonnées récupérées :", metadata);

    // Extraire les informations utiles depuis les métadonnées
    const ticketName =
      metadata.attributes.find((attr) => attr.trait_type === "name")?.value ||
      "Ticket Standard";
    const eventName =
      metadata.attributes.find((attr) => attr.trait_type === "Événement")
        ?.value || null;
    const ticketType =
      metadata.attributes.find((attr) => attr.trait_type === "Type de ticket")
        ?.value || "Standard";
    const qrCode =
      metadata.attributes.find((attr) => attr.trait_type === "QR Code")
        ?.value || null;
    const nftImageUrl = metadata.image || null;

    console.log(
      " Recherche de l'événement dans la base avec un nom proche :",
      eventName
    );

    const [eventResult] = await db.query(
      "SELECT idEvenement FROM evenement WHERE LOWER(nom) LIKE LOWER(?)",
      [`%${eventName}%`]
    );

    console.log("📡 Résultat de la recherche :", eventResult);

    if (eventResult.length === 0) {
      return res.status(400).json({
        message: "L'événement n'existe pas dans la base de données.",
      });
    }
    const evenementId = eventResult[0].idEvenement;

    console.log("Ticket Name :", ticketName);
    console.log("Type :", ticketType);
    console.log("Événement Name :", eventName);
    console.log("QR Code :", qrCode);
    console.log("Image URL :", nftImageUrl);

    // Mise à jour de la table `ticket`
    const [updateTicket] = await db.query(
      "UPDATE ticket SET ticket_name = ?, proprietaireId = ?, evenementId = ?, type = ?, qrCode = ?, stockageNFT = ?, imageURL = ? WHERE id = ?",
      [
        ticketName,
        proprietaireId,
        evenementId,
        ticketType,
        qrCode,
        mintId,
        nftImageUrl,
        ticketId,
      ]
    );

    console.log("Résultat de la mise à jour du ticket :", updateTicket);

    if (updateTicket.affectedRows === 0) {
      return res.status(500).json({
        message:
          "Mise à jour du ticket non effectuée. Vérifiez les valeurs envoyées.",
      });
    }

    res.status(200).json({
      message: "Ticket mis à jour avec succès",
      ticketId,
      ticketName,
      proprietaireId,
      evenementId,
      ticketType,
      qrCode,
      mintId,
      nftImageUrl,
    });
  } catch (error) {
    console.error("Erreur lors de l'update du ticket :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const scanTicket = async (req, res) => {
  const { imageURL, scannerId } = req.body;

  if (!imageURL || !scannerId) {
    return res
      .status(400)
      .json({ message: "Données incomplètes pour le scan du ticket." });
  }

  try {
    console.log("Scan du ticket avec Image URL :", imageURL);

    // Vérifier si le ticket existe via l'imageURL
    const [ticket] = await db.query("SELECT * FROM ticket WHERE imageURL = ?", [
      imageURL,
    ]);

    if (ticket.length === 0) {
      return res
        .status(404)
        .json({ message: "Ticket invalide ou inexistant." });
    }

    const ticketData = ticket[0];
    console.log("Ticket trouvé :", ticketData);
    console.log("Valeur actuelle de scanned :", ticketData.scanned);

    // Vérifier si le ticket a déjà été scanné
    if (ticketData.scanned) {
      console.log("⚠️ Ticket déjà scanné ! ID :", ticketData.id);
      return res.status(400).json({
        message: "Ce ticket a déjà été scanné !",
        ticket: { id: ticketData.id },
      });
    }

    // Enregistrer le scan et l'entrée du participant
    await db.query(
      "UPDATE ticket SET scanned = 1, scannerId = ?, scanDate = NOW() WHERE imageURL = ?",
      [scannerId, imageURL]
    );
    console.log("✅ Ticket marqué comme scanné !");

    console.log("Ticket validé et enregistré :", ticketData.id);

    // Récupérer les détails du ticket et de l'événement
    const [eventDetails] = await db.query(
      "SELECT e.nom AS eventName, e.date AS eventDate, t.ticket_name, t.type, t.imageURL " +
        "FROM ticket t INNER JOIN evenement e ON t.evenementId = e.idEvenement WHERE t.imageURL = ?",
      [imageURL]
    );

    res.status(200).json({
      message: "Ticket validé avec succès",
      ticket: {
        id: ticketData.id,
        ticketName: ticketData.ticket_name,
        ticketType: ticketData.type,
        imageUrl: ticketData.imageURL,
        scanned: true,
      },
      event: eventDetails[0],
    });
  } catch (error) {
    console.error("Erreur lors du scan du ticket :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};
