import express from "express";
import {
  searchEvents,
  getEventImages,
  getEventsForEvent,
  getEventById,
} from "../controllers/eventController.js";
import { getEventsForHome } from "../controllers/eventController.js";

const router = express.Router();

router.get("/:id/images", getEventImages);
router.get("/home", getEventsForHome);
router.get("/forEvent", getEventsForEvent);
router.get("/search", searchEvents);
router.get("/:id", getEventById);

export default router;
