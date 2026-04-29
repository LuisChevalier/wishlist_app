import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { prisma } from '../index';

/**
 * Controlador para gestionar el registro y login de usuarios.
 */
export const AuthController = {
  /**
   * Registra un nuevo usuario en la base de datos SQL.
   */
  register: async (req: Request, res: Response) => {
    const { username, password } = req.body;

    if (!username || !password) {
      return res.status(400).json({ error: 'Nombre de usuario y contraseña requeridos.' });
    }

    try {
      // Verificar si el usuario ya existe (Unique Constraint)
      const existingUser = await prisma.user.findUnique({ where: { username } });
      if (existingUser) {
        return res.status(400).json({ error: 'El nombre de usuario ya está en uso.' });
      }

      // Encriptar la contraseña (Hashing)
      const salt = await bcrypt.genSalt(10);
      const passwordHash = await bcrypt.hash(password, salt);

      // Guardar en SQL mediante Prisma
      const newUser = await prisma.user.create({
        data: { username, passwordHash }
      });

      res.status(201).json({ 
        message: 'Usuario registrado exitosamente.',
        userId: newUser.id 
      });
    } catch (error) {
      res.status(500).json({ error: 'Error al registrar usuario.' });
    }
  },

  /**
   * Valida credenciales y genera un token JWT de sesión.
   */
  login: async (req: Request, res: Response) => {
    const { username, password } = req.body;

    try {
      // Buscar el usuario por su nombre único
      const user = await prisma.user.findUnique({ where: { username } });
      if (!user) {
        return res.status(401).json({ error: 'Credenciales inválidas.' });
      }

      // Comparar el hash de la base de datos con la contraseña recibida
      const isMatch = await bcrypt.compare(password, user.passwordHash);
      if (!isMatch) {
        return res.status(401).json({ error: 'Credenciales inválidas.' });
      }

      // Generar el token firmado
      const secret = process.env.JWT_SECRET || 'fallback-secret';
      const token = jwt.sign(
        { userId: user.id, username: user.username },
        secret,
        { expiresIn: '7d' } // Sesión válida por 7 días
      );

      res.json({
        token,
        userId: user.id,
        username: user.username
      });
    } catch (error) {
      res.status(500).json({ error: 'Error en el proceso de login.' });
    }
  }
};
