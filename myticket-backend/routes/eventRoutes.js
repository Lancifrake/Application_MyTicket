import express from 'express';
import {getEventImages, getEventsForEvent} from '../controllers/eventController.js';
import { getEventsForHome } from '../controllers/eventController.js';

const router = express.Router();

router.get('/:id/images', getEventImages);
router.get('/home', getEventsForHome);
router.get('/forEvent', getEventsForEvent)

export default router;
