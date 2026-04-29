import { Request, Response, NextFunction } from 'express';
import jwt from 'jsonwebtoken';

// Estructura que esperamos dentro del token JWT
interface JwtPayload {
  userId: string;
  username: string;
}

/**
 * Middleware para proteger rutas que requieren autenticación.
 * Verifica si existe un token JWT válido en la cabecera 'Authorization'.
 */
export const authenticateToken = (req: Request, res: Response, next: NextFunction) => {
  const authHeader = req.headers['authorization'];
  // El token suele venir como 'Bearer <token>'
  const token = authHeader && authHeader.split(' ')[1];

  if (!token) {
    return res.status(401).json({ error: 'Acceso denegado. No se proporcionó un token.' });
  }

  try {
    const secret = process.env.JWT_SECRET || 'fallback-secret';
    const decoded = jwt.verify(token, secret) as JwtPayload;
    
    // Adjuntar la información del usuario al objeto request para su uso en controladores
    (req as any).user = decoded;
    
    next(); // Continuar a la siguiente función/controlador
  } catch (error) {
    return res.status(403).json({ error: 'Token inválido o expirado.' });
  }
};
