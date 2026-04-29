# Admin Panel Environment Setup

## Required Environment Variables

Create a `.env` file in the AdminPanel directory with the following variables:

```env
# Backend API URL (change this for production deployment)
VITE_API_URL=http://localhost:8000/api/admin

# Image URL for displaying images
VITE_IMG_URL=http://localhost:8000/storage
```

## Production Deployment

For production deployment, update the environment variables:

```env
# Production API URL
VITE_API_URL=https://your-domain.com/api/admin

# Production Image URL
VITE_IMG_URL=https://your-domain.com/storage
```

## Development

1. Copy the environment variables above to a `.env` file
2. Run `npm run dev` to start the development server
3. The admin panel will connect to the backend API automatically
