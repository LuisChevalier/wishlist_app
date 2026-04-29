import { Router } from 'express';
import { AuthController } from '../controllers/auth.controller';

const router = Router();

// Endpoint de Registro: /api/auth/register
router.post('/register', AuthController.register);

// Endpoint de Login: /api/auth/login
router.post('/login', AuthController.login);

export default router;
