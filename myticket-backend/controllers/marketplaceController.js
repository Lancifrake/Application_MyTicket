import { db } from "../config/db.js";
import { updateNFTPrice } from "../services/nftService.js";
import axios from "axios";

const MAX_MULTIPLICATEUR = 1.5;
const COMMISSION_PERCENTAGE = 8;

export const revendreNFT = async (req, res) => {
  const { ticketId, vendeurId, nouveauPrix } = req.body;

  if (!ticketId || !vendeurId || !nouveauPrix) {
    return res
      .status(400)
      .json({ message: "Données incomplètes pour la mise en vente." });
  }

  try {
    console.log("Mise en vente du NFT :", {
      ticketId,
      vendeurId,
      nouveauPrix,
    });

    // Vérifier si le ticket appartient bien au vendeur
    const [ticket] = await db.query(
      "SELECT proprietaireId, stockageNFT FROM ticket WHERE id = ?",
      [ticketId]
    );

    if (ticket.length === 0 || ticket[0].proprietaireId !== vendeurId) {
      return res
        .status(403)
        .json({ message: " Vous ne possédez pas ce ticket." });
    }
    // Vérifier que le prix ne dépasse pas le plafond (2x du prix initial)
    if (nouveauPrix > ticket[0].prix_initial * MAX_MULTIPLICATEUR) {
      return res
        .status(400)
        .json({ message: " Le prix dépasse la limite autorisée." });
    }

    const mintId = ticket[0].stockageNFT;

    // Insérer le ticket dans la marketplace
    const [result] = await db.query(
      "INSERT INTO marketplace (ticketId, vendeurId, prix, statut) VALUES (?, ?, ?, 'en vente')",
      [ticketId, vendeurId, nouveauPrix]
    );

    console.log(" Ticket mis en vente avec succès :");
    res.status(201).json({
      message: " Ticket mis en vente avec succès.",
    });
  } catch (error) {
    console.error(" Erreur lors de la mise en vente :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const acheterNFTRevente = async (req, res) => {
  const { annonceId, acheteurId, phoneNumber } = req.body;

  if (!annonceId || !acheteurId || !phoneNumber) {
    return res.status(400).json({ message: "Données incomplètes." });
  }

  try {
    console.log("Achat d'un ticket revendu :", {
      annonceId,
      acheteurId,
      phoneNumber,
    });

    // Vérifier si le ticket est toujours en vente
    const [annonce] = await db.query(
      "SELECT ticketId, vendeurId, prix FROM marketplace WHERE id = ? AND statut = 'en vente'",
      [annonceId]
    );
    if (annonce.length === 0) {
      return res
        .status(400)
        .json({ message: "Ce ticket n'est plus disponible." });
    }

    const { ticketId, vendeurId, prix } = annonce[0];
    const commission = (prix * 8) / 100; // 8% de frais fixés dans la Candy Machine
    const montantVendeur = prix - commission;

    console.log(`Commission (8%) : ${commission} FCFA`);
    console.log(`Montant à verser au vendeur : ${montantVendeur} FCFA`);

    // Simulation du paiement (à intégrer)
    console.log("Paiement validé, début du transfert du NFT...");

    // Récupération du mintId du ticket
    const [ticket] = await db.query(
      "SELECT stockageNFT FROM ticket WHERE id = ?",
      [ticketId]
    );
    if (ticket.length === 0) {
      return res
        .status(400)
        .json({ message: "Ce ticket n'a pas de NFT associé." });
    }

    const mintId = ticket[0].stockageNFT;
    console.log(`NFT associé au ticket : ${mintId}`);

    // Transfert du NFT via le microservice WSL2
    console.log(
      `Envoi de la requête de transfert vers le microservice WSL2...`
    );
    const [acheteur] = await db.query(
      "SELECT walletAddress FROM personne WHERE id = ?",
      [acheteurId]
    );
    if (acheteur.length === 0) {
      return res.status(400).json({ message: "Acheteur non trouvé." });
    }
    const vendeurWallet = "CUBfvxTBvXpeifCRYhPwLsHBnRK65WK26VYX9u8fbYni";
    const acheteurWallet = acheteur[0].walletAddress;

    console.log(`Transfert du NFT de ${vendeurWallet} vers ${acheteurWallet}`);

    const transferResponse = await axios.post(
      "http://172.18.129.5:3001/transferNFT",
      {
        mintId,
        vendeurWallet: vendeurWallet,
        acheteurWallet: acheteurWallet,
      },
      { headers: { "Content-Type": "application/json" } }
    );

    console.log("Réponse du service de transfert :", transferResponse.data);

    if (transferResponse.data.message !== "NFT transféré avec succès") {
      return res
        .status(500)
        .json({ message: "Erreur lors du transfert du NFT." });
    }

    console.log(
      "NFT transféré avec succès ! Mise à jour en base de données..."
    );

    // Mise à jour du propriétaire du ticket en base
    await db.query("UPDATE ticket SET proprietaireId = ? WHERE id = ?", [
      acheteurId,
      ticketId,
    ]);

    // Marquer le ticket comme vendu sur la marketplace
    await db.query(
      "UPDATE marketplace SET statut = 'vendu', acheteurId = ?, dateVente = NOW() WHERE ticketId = ?",
      [acheteurId, ticketId]
    );

    console.log("Ticket vendu et NFT transféré !");
    res
      .status(200)
      .json({ message: "Ticket acheté et NFT transféré avec succès !" });
  } catch (error) {
    console.error("Erreur lors de l'achat du ticket :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const getTicketsEnVente = async (req, res) => {
  try {
    console.log("Récupération des tickets en vente...");
    const [tickets] = await db.query(
      "SELECT m.id AS annonceId, m.ticketId, t.ticket_name, t.type, m.vendeurId, m.prix, m.dateMiseEnVente, t.imageURL " +
        "FROM marketplace m INNER JOIN ticket t ON m.ticketId = t.id WHERE m.statut = 'en vente'"
    );

    res.status(200).json({ tickets });
  } catch (error) {
    console.error(
      "Erreur lors de la récupération des tickets en vente :",
      error.message
    );
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const getMarketplaceTickets = async (req, res) => {
  try {
    const [tickets] = await db.query(
      `SELECT 
        m.id AS marketplaceId, 
        m.ticketId, 
        m.vendeurId, 
        m.prix, 
        t.ticket_name, 
        t.imageURL, 
        e.nom AS evenementNom, 
        e.lieu, 
        e.date
      FROM marketplace m
      INNER JOIN ticket t ON m.ticketId = t.id
      INNER JOIN evenement e ON t.evenementId = e.idEvenement
      WHERE m.statut = 'en vente'`
    );

    res.status(200).json(tickets);
  } catch (error) {
    console.error(
      "Erreur lors de la récupération des tickets en vente :",
      error.message
    );
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const listTicketForSale = async (req, res) => {
  console.log("Requête reçue pour mettre en vente un ticket !");
  console.log("Données reçues:", req.body);
  const { ticketId, vendeurId, prix } = req.body;

  if (!ticketId || !vendeurId || !prix) {
    console.log("Erreur : Données incomplètes !");
    return res
      .status(400)
      .json({ message: "Données incomplètes pour la mise en vente." });
  }

  try {
    console.log("Mise en vente d'un ticket :", { ticketId, vendeurId, prix });

    // Vérifier si le ticket appartient bien au vendeur
    const [ticket] = await db.query(
      "SELECT proprietaireId, type, stockageNFT FROM ticket WHERE id = ?",
      [ticketId]
    );

    if (ticket.length === 0) {
      console.log("Ticket introuvable !");
      return res.status(404).json({ message: "Ticket introuvable." });
    }

    if (ticket[0].proprietaireId !== vendeurId) {
      console.log("Ce ticket n'appartient pas au vendeur !");
      return res
        .status(403)
        .json({ message: "Vous ne possédez pas ce ticket." });
    }
    console.log("Vérification si le ticket est déjà en vente...");

    // Vérifier si le ticket n'est pas déjà en vente
    const [existingSale] = await db.query(
      "SELECT id FROM marketplace WHERE ticketId = ? AND statut = 'en vente'",
      [ticketId]
    );

    if (existingSale.length > 0) {
      return res.status(400).json({ message: "Ce ticket est déjà en vente." });
    }

    // Vérifier le plafond de prix (max 2× le prix initial)
    const prixInitial = 20000;
    const plafondPrix = prixInitial * 1.5;

    console.log("Vérification du prix...");
    console.log(
      `Prix demandé : ${prix} | Prix initial : ${prixInitial} | Plafond autorisé : ${plafondPrix}`
    );

    if (prix > plafondPrix) {
      return res.status(400).json({
        message: `Le prix demandé dépasse le plafond autorisé (${plafondPrix} XAF).`,
      });
    }

    // Insérer le ticket en vente dans la marketplace
    await db.query(
      "INSERT INTO marketplace (ticketId, vendeurId, prix, dateMiseEnVente, statut ) VALUES (?, ?, ?, NOW(), 'en vente')",
      [ticketId, vendeurId, prix]
    );

    console.log("Ticket mis en vente avec succès !");
    res.status(200).json({ message: "Ticket mis en vente avec succès !" });
  } catch (error) {
    console.error("Erreur lors de la mise en vente :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const buyTicket = async (req, res) => {
  const { ticketId, acheteurId, prix } = req.body;

  if (!ticketId || !acheteurId || !prix) {
    return res
      .status(400)
      .json({ message: "Données incomplètes pour l'achat" });
  }

  try {
    // Vérifier si le ticket est bien en vente
    const [ticketForSale] = await db.query(
      "SELECT * FROM marketplace WHERE ticketId = ? AND statut = 'en vente'",
      [ticketId]
    );

    if (ticketForSale.length === 0) {
      return res
        .status(404)
        .json({ message: "Ticket non disponible à la vente" });
    }

    const vendeurId = ticketForSale[0].vendeurId;

    // Mettre à jour la table marketplace
    await db.query(
      "UPDATE marketplace SET statut = 'vendu', acheteurId = ?, dateVente = NOW() WHERE ticketId = ?",
      [acheteurId, ticketId]
    );

    // Mettre à jour la table ticket avec le nouveau propriétaire
    await db.query("UPDATE ticket SET proprietaireId = ? WHERE id = ?", [
      acheteurId,
      ticketId,
    ]);

    res.status(200).json({ message: "Ticket acheté avec succès !" });
  } catch (error) {
    console.error("Erreur lors de l'achat du ticket :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};

export const transferTicket = async (req, res) => {
  const { ticketId, vendeurId, acheteurId } = req.body;

  if (!ticketId || !vendeurId || !acheteurId) {
    return res
      .status(400)
      .json({ message: "Données incomplètes pour le transfert." });
  }

  try {
    console.log("Transfert du ticket :", { ticketId, vendeurId, acheteurId });

    // 1. Vérifier si le ticket appartient bien au vendeur
    const [ticket] = await db.query(
      "SELECT proprietaireId, stockageNFT FROM ticket WHERE id = ?",
      [ticketId]
    );

    // if (ticket.length === 0 || ticket[0].proprietaireId !== vendeurId) {
    //   return res.status(403).json({ message: "Vous ne possédez pas ce ticket." });
    // }

    const mintId = ticket[0].stockageNFT;

    const [destinataire] = await db.query(
      "SELECT walletAddress FROM personne WHERE id = ?",
      [acheteurId]
    );

    if (destinataire.length === 0) {
      return res.status(404).json({ message: "Utilisateur non trouvé." });
    }

    const vendeurWallet = "CUBfvxTBvXpeifCRYhPwLsHBnRK65WK26VYX9u8fbYni";
    const acheteurWallet = destinataire[0].walletAddress;

    console.log(`Transfert du NFT de ${vendeurWallet} vers ${acheteurWallet}`);

    // 3. Transférer le NFT via le microservice
    const transferResponse = await axios.post(
      "http://172.18.129.5:3001/transferNFT",
      {
        mintId,
        vendeurWallet,
        acheteurWallet,
      },
      { headers: { "Content-Type": "application/json" } }
    );

    if (transferResponse.data.message !== "NFT transféré avec succès") {
      return res.status(500).json({
        message: "Erreur lors du transfert du NFT.",
        details: transferResponse.data,
      });
    }

    // 4. Mettre à jour le propriétaire du ticket en base
    await db.query("UPDATE ticket SET proprietaireId = ? WHERE id = ?", [
      acheteurId,
      ticketId,
    ]);

    // 5. Enregistrer le transfert dans l'historique (optionnel)
    // await db.query("INSERT INTO transferts (ticketId, expediteurId, destinataireId, dateTransfert) VALUES (?, ?, ?, NOW())", [
    //   ticketId,
    //   vendeurId,
    //   acheteurId
    // ]);

    console.log("Ticket transféré avec succès!");
    res.status(200).json({
      message: "Ticket transféré avec succès !",
      ticketId,
      nouveauProprietaire: acheteurId,
    });
  } catch (error) {
    console.error("Erreur lors du transfert du ticket :", error.message);
    res.status(500).json({ message: "Erreur serveur", error: error.message });
  }
};
