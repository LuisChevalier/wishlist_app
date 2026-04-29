import { Request, Response } from 'express';
import { prisma } from '../index';

/**
 * Controlador para la gestión de la lista de deseos.
 * Solo puede ser accedido por usuarios autenticados.
 */
export const WishlistController = {
  /**
   * Obtiene todos los ítems pertenecientes al usuario autenticado.
   */
  getItems: async (req: Request, res: Response) => {
    const { userId } = (req as any).user;

    try {
      // Filtrar deseos por ID de usuario para garantizar su privacidad
      const items = await prisma.wishlistItem.findMany({
        where: { userId },
        orderBy: { createdAt: 'desc' }
      });
      res.json(items);
    } catch (error) {
      res.status(500).json({ error: 'Fallo al recuperar ítems.' });
    }
  },

  /**
   * Crea un nuevo ítem asociado al usuario autenticado.
   */
  createItem: async (req: Request, res: Response) => {
    const { userId } = (req as any).user;
    const { name, price, priority, imageUri, purchaseLocation, expectedDate, notes, isPurchased } = req.body;

    if (!name) {
      return res.status(400).json({ error: 'El nombre del ítem es obligatorio.' });
    }

    try {
      const newItem = await prisma.wishlistItem.create({
        data: {
          name,
          price: price || 0,
          priority: priority || 1, // Default Media
          imageUri: imageUri || null,
          purchaseLocation: purchaseLocation || null,
          expectedDate: expectedDate ? new Date(expectedDate) : null,
          notes: notes || null,
          isCompleted: isPurchased || false, // Flutter maps to isCompleted
          userId // Asociación automática via FK
        }
      });
      res.status(201).json(newItem);
    } catch (error) {
      res.status(500).json({ error: 'Error al crear el deseo.' });
    }
  },

  /**
   * Actualiza los datos de un deseo existente. 
   * Previene modificar ítems ajenos mediante la validación de propiedad.
   */
  updateItem: async (req: Request, res: Response) => {
    const { userId } = (req as any).user;
    const { id } = req.params;
    const { name, price, priority, isCompleted, isPurchased, imageUri, purchaseLocation, expectedDate, notes } = req.body;

    try {
      // Verificación de pertenencia: Solo el dueño puede editar
      const item = await prisma.wishlistItem.findUnique({ where: { id: id as string } });
      if (!item || item.userId !== userId) {
        return res.status(403).json({ error: 'No tienes permiso para modificar este ítem o no existe.' });
      }
      
      const finalIsCompleted = isPurchased !== undefined ? isPurchased : isCompleted;

      const updated = await prisma.wishlistItem.update({
        where: { id: id as string },
        data: { 
          name, 
          price, 
          priority, 
          isCompleted: finalIsCompleted, 
          imageUri,
          purchaseLocation,
          expectedDate: expectedDate ? new Date(expectedDate) : undefined,
          notes
        }
      });
      res.json(updated);
    } catch (error) {
      res.status(500).json({ error: 'Error al actualizar el deseo.' });
    }
  },

  /**
   * Elimina un deseo de forma permanente de la base de datos SQL.
   */
  deleteItem: async (req: Request, res: Response) => {
    const { userId } = (req as any).user;
    const { id } = req.params;

    try {
      // Verificación de pertenencia: Solo el dueño puede eliminar
      const item = await prisma.wishlistItem.findUnique({ where: { id: id as string } });
      if (!item || item.userId !== userId) {
        return res.status(403).json({ error: 'No tienes permiso para eliminar este ítem.' });
      }

      await prisma.wishlistItem.delete({ where: { id: id as string } });
      res.json({ message: 'Ítem eliminado exitosamente.' });
    } catch (error) {
      res.status(500).json({ error: 'Error al eliminar el deseo.' });
    }
  }
};
