import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import { PrismaClient } from '@prisma/client';

// Cargar variables de entorno desde el archivo .env
dotenv.config();

// Instancia global de Prisma centrada en la eficiencia de conexiones.
export const prisma = new PrismaClient();

import authRoutes from './routes/auth.routes';
import wishlistRoutes from './routes/wishlist.routes';

const app = express();
const PORT = process.env.PORT || 3000;

// -- MIDDLEWARES --
app.use(cors());
app.use(express.json());

// -- RUTAS --
// Registro e inicio de sesión
app.use('/api/auth', authRoutes);
// Gestión de deseos (Protegida)
app.use('/api/wishlist', wishlistRoutes);

// Ruta de prueba para verificar salud del servidor
app.get('/health', (req: Request, res: Response) => {
  res.json({ 
    status: 'online', 
    timestamp: new Date().toISOString(),
    db: 'connected' // Idealmente verificar conexión real aquí
  });
});

// -- MANEJO DE ERRORES CENTRALIZADO --
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('[SERVER ERROR]:', err.stack);
  res.status(500).json({ 
    error: 'Algo salió mal en el servidor!', 
    message: process.env.NODE_ENV === 'development' ? err.message : undefined 
  });
});

// -- ARRANQUE DEL SERVIDOR --
async function main() {
  try {
    // Intentar conectar con la base de datos antes de escuchar
    await prisma.$connect();
    console.log('✅ Conexión a la base de datos SQL exitosa.');
    
    app.listen(PORT, () => {
      console.log(`🚀 Servidor de Wishlist escuchando en http://localhost:${PORT}`);
    });
  } catch (error) {
    console.error('❌ Error fatal al arrancar el servidor:', error);
    process.exit(1);
  }
}

main();
