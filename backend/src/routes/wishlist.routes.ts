import { Router } from 'express';
import { WishlistController } from '../controllers/wishlist.controller';
import { authenticateToken } from '../middlewares/auth.middleware';

const router = Router();

// Todas las rutas de la wishlist requieren un token JWT válido
router.get('/', authenticateToken, WishlistController.getItems);
router.post('/', authenticateToken, WishlistController.createItem);
router.put('/:id', authenticateToken, WishlistController.updateItem);
router.delete('/:id', authenticateToken, WishlistController.deleteItem);

export default router;
