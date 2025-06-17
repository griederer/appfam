/** @type {import('next').NextConfig} */
const nextConfig = {
  experimental: {
    appDir: true,
  },
  images: {
    domains: [
      'localhost',
      'family-hub.vercel.app',
      // Add your Supabase storage domain when you set it up
      // 'your-project.supabase.co'
    ],
  },
  env: {
    CUSTOM_KEY: process.env.CUSTOM_KEY,
  },
  // Enable webpack bundle analyzer in development
  webpack: (config, { dev, isServer }) => {
    // Add any custom webpack configuration here
    if (dev && !isServer) {
      // Development optimizations
      config.optimization.splitChunks = {
        chunks: 'all',
        cacheGroups: {
          vendor: {
            test: /[\\/]node_modules[\\/]/,
            name: 'vendors',
            chunks: 'all',
          },
        },
      }
    }
    return config
  },
  // Security headers
  async headers() {
    return [
      {
        source: '/(.*)',
        headers: [
          {
            key: 'X-Content-Type-Options',
            value: 'nosniff',
          },
          {
            key: 'X-Frame-Options',
            value: 'DENY',
          },
          {
            key: 'X-XSS-Protection',
            value: '1; mode=block',
          },
          {
            key: 'Referrer-Policy',
            value: 'strict-origin-when-cross-origin',
          },
        ],
      },
    ]
  },
  // Redirects
  async redirects() {
    return [
      {
        source: '/dashboard',
        destination: '/dashboard/tasks',
        permanent: false,
      },
    ]
  },
}

module.exports = nextConfig