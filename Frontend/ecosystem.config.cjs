module.exports = {
  apps: [
    {
      name: 'buyingat-frontend',
      script: 'npm',
      args: 'run dev',
      cwd: '/root/BuyingAt_Frontend',
      instances: 1,
      autorestart: true,
      watch: false,
      max_memory_restart: '1G',
      env: {
        NODE_ENV: 'development',
        PORT: 3000
      },
      error_file: '/root/BuyingAt_Frontend/logs/err.log',
      out_file: '/root/BuyingAt_Frontend/logs/out.log',
      log_file: '/root/BuyingAt_Frontend/logs/combined.log',
      time: true
    }
  ]
};
