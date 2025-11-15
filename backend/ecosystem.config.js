module.exports = {
  apps: [{
    name: 'medical-api',
    script: 'npm',
    args: 'run start',
    cwd: '/var/www/medical-backend',
    instances: 1,
    autorestart: true,
    watch: false,
    max_memory_restart: '1G',
    env: {
      NODE_ENV: 'production',
      PORT: 3000
    },
    error_file: '/root/.pm2/logs/medical-api-error.log',
    out_file: '/root/.pm2/logs/medical-api-out.log',
    log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
    merge_logs: true
  }]
}

