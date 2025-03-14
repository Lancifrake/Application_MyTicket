import express from "express";
import {
  initiatePayment,
  mintNFTAfterPayment,
  storeMintedNFT,
} from "../controllers/paymentController.js";

const router = express.Router();

router.post("/init", initiatePayment);
router.post("/mint", mintNFTAfterPayment);
router.post("/storeNFT", storeMintedNFT);
router.get("/success", (req, res) => {
  res.send("<h1>✅ Paiement réussi !</h1><p>Merci pour votre achat.</p>");
});

export default router;
