import express from "express";
import {
  revendreNFT,
  acheterNFTRevente,
  getTicketsEnVente,
  listTicketForSale,
  transferTicket,
} from "../controllers/marketplaceController.js";

const router = express.Router();

router.post("/revendre", revendreNFT);
router.post("/acheter-revente", acheterNFTRevente);
router.get("/tickets-en-vente", getTicketsEnVente);
router.post("/list-ticket", listTicketForSale);
router.post("/transfer", transferTicket);

export default router;
