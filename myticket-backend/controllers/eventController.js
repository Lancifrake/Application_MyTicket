import { db } from '../config/db.js';

export const getEventImages = async (req, res) => {
    const eventId = req.params.id;
    console.log("ID de l'événement :", eventId);  // Vérifie que l'ID est bien reçu

    try {
        const [rows] = await db.query('SELECT imagePath FROM event_images WHERE idEvenement = ?', [eventId]);
        console.log("Résultat de la requête :", rows);  // Log le résultat de la requête

        if (rows.length === 0) {
            return res.status(404).json({ message: 'Aucune image trouvée pour cet événement.' });
        }

        const images = rows.map((row) => row.imagePath);
        console.log("Images trouvées :", images);  // Log les images avant de les renvoyer
        res.json({ eventId, images });
    } catch (error) {
        console.error('Erreur lors de la récupération des images :', error);  // Log détaillé de l'erreur
        res.status(500).json({ message: 'Erreur serveur' });
    }
};
export const getEventsForHome = async (req, res) => {
    try {
        const query = `
      SELECT e.idEvenement, e.nom, e.lieu, e.date, 
             (SELECT imagePath FROM event_images WHERE idEvenement = e.idEvenement LIMIT 1) AS imagePath
      FROM evenement e
    `;

        const [rows] = await db.query(query);
        res.json(rows);
    } catch (error) {
        console.error('Erreur lors de la récupération des événements :', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};
export const getEventsForEvent = async (req, res) => {
    try {
        const [rows] = await db.query(`
            SELECT e.idEvenement, e.nom, e.lieu, e.date, e.description, ei.imagePath
            FROM evenement e
                     LEFT JOIN event_images ei ON e.idEvenement = ei.idEvenement
    `);
        res.json(rows);
    } catch (error) {
        console.error('Erreur lors de la récupération des événements :', error);
        res.status(500).json({ message: 'Erreur serveur' });
    }
};
export const searchEvents = async (req, res) => {
    const { query } = req.query;

    if (!query) {
        return res.status(400).json({ message: "Le paramètre 'query' est requis" });
    }

    try {
        const [results] = await db.query(
            `
      SELECT idEvenement, nom, lieu, date, description 
      FROM evenement 
      WHERE nom LIKE ? OR lieu LIKE ? OR description LIKE ?
      `,
            [`%${query}%`, `%${query}%`, `%${query}%`]
        );

        res.status(200).json(results);
    } catch (error) {
        console.error("Erreur lors de la recherche :", error);
        res.status(500).json({ message: "Erreur serveur" });
    }
};


