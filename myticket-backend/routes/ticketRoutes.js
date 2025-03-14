import express from "express";
import {
  getUserTickets,
  createTicket,
  scanTicket,
  updateTicketAfterMint,
} from "../controllers/ticketController.js"; // Import nommé

const router = express.Router();

router.get("/user/:userId", getUserTickets);
router.post("/scan", scanTicket);
router.post("/createTicket", createTicket);
router.post("/updateAfterMint", updateTicketAfterMint);

export default router;
