import express from "express";
import { verifyToken, checkRole } from "../middleware/authMiddleware.js";
import { reportFraudTicket } from "../controllers/scannerController.js";

const router = express.Router();

router.get("/", verifyToken, checkRole(["scanner", "admin"]), (req, res) => {
  res.json({ message: "Bienvenue, scanner !" });
});
router.post("/report-fraud", reportFraudTicket);

export default router;
