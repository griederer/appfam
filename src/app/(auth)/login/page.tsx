'use client'

import { useState } from 'react'
import Link from 'next/link'
import { useRouter } from 'next/navigation'

export default function LoginPage() {
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [loading, setLoading] = useState(false)
  const [error, setError] = useState('')
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault()
    setLoading(true)
    setError('')

    try {
      // TODO: Implement Supabase login
      console.log('Login with:', email, password)
      // For now, just redirect to dashboard
      router.push('/dashboard')
    } catch (err) {
      setError('Failed to login. Please try again.')
    } finally {
      setLoading(false)
    }
  }

  return (
    <div className="min-h-screen bg-background-main flex items-center justify-center px-4">
      <div className="max-w-md w-full">
        <div className="card p-8">
          <h1 className="text-2xl font-bold text-center mb-8">Welcome Back</h1>
          
          <form onSubmit={handleSubmit} className="space-y-6">
            {error && (
              <div className="bg-red-50 text-red-600 p-3 rounded-button text-sm">
                {error}
              </div>
            )}
            
            <div>
              <label htmlFor="email" className="block text-sm font-medium text-gray-700 mb-2">
                Email
              </label>
              <input
                id="email"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="input-primary"
                placeholder="you@example.com"
                required
              />
            </div>
            
            <div>
              <label htmlFor="password" className="block text-sm font-medium text-gray-700 mb-2">
                Password
              </label>
              <input
                id="password"
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="input-primary"
                placeholder="••••••••"
                required
              />
            </div>
            
            <button
              type="submit"
              disabled={loading}
              className="w-full btn-primary"
            >
              {loading ? 'Signing in...' : 'Sign In'}
            </button>
          </form>
          
          <p className="text-center mt-6 text-sm text-gray-600">
            Don't have an account?{' '}
            <Link href="/signup" className="text-accent-blue hover:underline">
              Sign up
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}