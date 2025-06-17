import type { Metadata } from 'next'
import { Inter } from 'next/font/google'
import './globals.css'

const inter = Inter({ 
  subsets: ['latin'],
  variable: '--font-inter',
  display: 'swap',
})

export const metadata: Metadata = {
  title: 'Family Hub',
  description: 'A minimalist family management app inspired by Things 3',
  keywords: ['family', 'tasks', 'calendar', 'grocery', 'management'],
  authors: [{ name: 'Gonzalo Family' }],
  viewport: 'width=device-width, initial-scale=1',
  themeColor: '#007AFF',
  manifest: '/manifest.json',
  icons: {
    icon: '/favicon.ico',
    apple: '/apple-touch-icon.png',
  },
  openGraph: {
    title: 'Family Hub',
    description: 'A minimalist family management app',
    type: 'website',
    locale: 'en_US',
  },
  twitter: {
    card: 'summary_large_image',
    title: 'Family Hub',
    description: 'A minimalist family management app',
  },
}

export default function RootLayout({
  children,
}: {
  children: React.ReactNode
}) {
  return (
    <html lang="en" className={inter.variable}>
      <head>
        {/* Preconnect to external resources */}
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossOrigin="anonymous" />
        
        {/* DNS prefetch for better performance */}
        <link rel="dns-prefetch" href="//fonts.googleapis.com" />
        
        {/* Security headers via meta tags */}
        <meta httpEquiv="X-Content-Type-Options" content="nosniff" />
        <meta httpEquiv="X-Frame-Options" content="DENY" />
        <meta httpEquiv="X-XSS-Protection" content="1; mode=block" />
        <meta name="referrer" content="strict-origin-when-cross-origin" />
        
        {/* iOS specific meta tags */}
        <meta name="apple-mobile-web-app-capable" content="yes" />
        <meta name="apple-mobile-web-app-status-bar-style" content="default" />
        <meta name="apple-mobile-web-app-title" content="Family Hub" />
        
        {/* Android specific meta tags */}
        <meta name="mobile-web-app-capable" content="yes" />
        <meta name="application-name" content="Family Hub" />
      </head>
      <body className={`${inter.className} antialiased`}>
        {/* Skip to main content for accessibility */}
        <a 
          href="#main-content" 
          className="sr-only focus:not-sr-only focus:absolute focus:top-4 focus:left-4 
                     bg-accent-blue text-white px-4 py-2 rounded-button z-50"
        >
          Skip to main content
        </a>
        
        {/* Main application content */}
        <div id="app" className="min-h-screen bg-background-main">
          {children}
        </div>
        
        {/* Portal for modals and overlays */}
        <div id="modal-root"></div>
        
        {/* Development tools (only in development) */}
        {process.env.NODE_ENV === 'development' && (
          <script
            dangerouslySetInnerHTML={{
              __html: `
                // Add development helpers here if needed
                console.log('🏠 Family Hub - Development Mode');
              `,
            }}
          />
        )}
      </body>
    </html>
  )
}