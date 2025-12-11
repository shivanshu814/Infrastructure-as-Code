import express, { Request, Response, NextFunction } from 'express';
import cors from 'cors';
import helmet from 'helmet';
import morgan from 'morgan';
import dotenv from 'dotenv';

// Load environment variables
dotenv.config();

const app = express();
const PORT = process.env.PORT || 3000;
const NODE_ENV = process.env.NODE_ENV || 'development';

// Middleware
app.use(helmet()); // Security headers
app.use(cors()); // CORS enabled for all origins (restrict in production!)
app.use(express.json());
app.use(morgan('combined')); // HTTP request logging

// Health check endpoint (important for load balancer!)
app.get('/health', (req: Request, res: Response) => {
  res.status(200).json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    uptime: process.uptime(),
    environment: NODE_ENV,
  });
});

// Readiness check (for ECS/K8s)
app.get('/ready', (req: Request, res: Response) => {
  // Add database connectivity checks here if needed
  res.status(200).json({ ready: true });
});

// API routes
app.get('/api/info', (req: Request, res: Response) => {
  res.json({
    message: 'DevOps Learning Project API',
    version: '1.0.0',
    environment: NODE_ENV,
  });
});

// Example API endpoint with external service integration
app.get('/api/demo', async (req: Request, res: Response) => {
  try {
    // Simulate processing
    const data = {
      message: 'Hello from the backend!',
      timestamp: new Date().toISOString(),
      hostname: process.env.HOSTNAME || 'unknown',
      // Example: Using secrets from environment (not hardcoded!)
      hasApiKey: !!process.env.OPENROUTER_API_KEY,
      hasFalKey: !!process.env.FAL_KEY,
    };

    res.json(data);
  } catch (error) {
    console.error('Error in /api/demo:', error);
    res.status(500).json({ error: 'Internal server error' });
  }
});

// 404 handler
app.use((req: Request, res: Response) => {
  res.status(404).json({ error: 'Route not found' });
});

// Global error handler
app.use((err: Error, req: Request, res: Response, next: NextFunction) => {
  console.error('Error:', err);
  res.status(500).json({
    error: 'Internal server error',
    message: NODE_ENV === 'development' ? err.message : undefined,
  });
});

// Start server
app.listen(PORT, () => {
  console.log(`🚀 Server running on port ${PORT}`);
  console.log(`📊 Environment: ${NODE_ENV}`);
  console.log(`🔗 Health check: http://localhost:${PORT}/health`);
});

// Graceful shutdown (important for containers!)
process.on('SIGTERM', () => {
  console.log('SIGTERM signal received: closing HTTP server');
  process.exit(0);
});

process.on('SIGINT', () => {
  console.log('SIGINT signal received: closing HTTP server');
  process.exit(0);
});
