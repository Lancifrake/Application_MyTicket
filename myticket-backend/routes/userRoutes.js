import express from "express";
import {
  getUserProfile,
  updateUserProfile,
  getUserById,
  getUserTickets,
} from "../controllers/userController.js";
import { verifyToken, checkRole } from "../middleware/authMiddleware.js";

const router = express.Router();

router.get("/", verifyToken, checkRole(["utilisateur"]), (req, res) => {
  res.json({ message: `Bienvenue, utilisateur ${req.user.username} !` });
});
router.get("/profile", verifyToken, getUserProfile); // GET : Récupérer le profil
router.put("/update", verifyToken, updateUserProfile); // PUT : Mettre à jour le profil
router.get("/:userId", getUserById);
router.get("/tickets/:userId", getUserTickets);

export default router;
