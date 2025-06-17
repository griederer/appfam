import Link from 'next/link'
import { ArrowRight, CheckCircle, Calendar, ShoppingCart, Users } from 'lucide-react'

export default function HomePage() {
  return (
    <main id="main-content" className="min-h-screen bg-gradient-to-br from-blue-50 to-indigo-100">
      {/* Hero Section */}
      <div className="relative overflow-hidden">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 pt-20 pb-16">
          <div className="text-center">
            <h1 className="text-4xl md:text-6xl font-bold text-gray-900 mb-6">
              Family Hub
              <span className="block text-accent-blue mt-2">Simple. Beautiful. Organized.</span>
            </h1>
            <p className="text-xl text-gray-600 mb-8 max-w-3xl mx-auto leading-relaxed">
              A minimalist family management app inspired by Things 3. 
              Keep your family organized with tasks, groceries, and calendar - all in one beautiful place.
            </p>
            
            {/* CTA Buttons */}
            <div className="flex flex-col sm:flex-row gap-4 justify-center items-center">
              <Link 
                href="/auth/signup"
                className="btn-primary flex items-center gap-2 px-8 py-3 text-lg"
              >
                Get Started
                <ArrowRight className="w-5 h-5" />
              </Link>
              <Link 
                href="/auth/login"
                className="btn-secondary flex items-center gap-2 px-8 py-3 text-lg"
              >
                Sign In
              </Link>
            </div>
          </div>
        </div>
      </div>

      {/* Features Section */}
      <div className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-16">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Everything your family needs
            </h2>
            <p className="text-lg text-gray-600">
              Designed specifically for the Gonzalo, María Paz, Borja, and Melody household
            </p>
          </div>

          <div className="grid md:grid-cols-3 gap-8">
            {/* Task Management */}
            <div className="card text-center p-8 hover:shadow-card-hover transition-all duration-300">
              <div className="w-16 h-16 bg-accent-blue rounded-full flex items-center justify-center mx-auto mb-6">
                <CheckCircle className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Smart Task Management</h3>
              <p className="text-gray-600 mb-6">
                Organize tasks by time of day with family member assignments. 
                Morning, afternoon, and evening views keep everyone on track.
              </p>
              <ul className="text-sm text-gray-500 space-y-2">
                <li>• Time-based organization</li>
                <li>• Family member tagging</li>
                <li>• Real-time sync</li>
                <li>• Keyboard shortcuts</li>
              </ul>
            </div>

            {/* Grocery Lists */}
            <div className="card text-center p-8 hover:shadow-card-hover transition-all duration-300">
              <div className="w-16 h-16 bg-green-500 rounded-full flex items-center justify-center mx-auto mb-6">
                <ShoppingCart className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Smart Grocery Lists</h3>
              <p className="text-gray-600 mb-6">
                Never forget items again. Templates and purchase history make shopping effortless.
              </p>
              <ul className="text-sm text-gray-500 space-y-2">
                <li>• Reusable templates</li>
                <li>• Purchase history</li>
                <li>• Category organization</li>
                <li>• &quot;Always buy&quot; items</li>
              </ul>
            </div>

            {/* Family Calendar */}
            <div className="card text-center p-8 hover:shadow-card-hover transition-all duration-300">
              <div className="w-16 h-16 bg-purple-500 rounded-full flex items-center justify-center mx-auto mb-6">
                <Calendar className="w-8 h-8 text-white" />
              </div>
              <h3 className="text-xl font-semibold text-gray-900 mb-4">Family Calendar</h3>
              <p className="text-gray-600 mb-6">
                Beautiful month view with color-coded events for each family member.
              </p>
              <ul className="text-sm text-gray-500 space-y-2">
                <li>• Color-coded by person</li>
                <li>• Click to create events</li>
                <li>• Drag to reschedule</li>
                <li>• Today highlighting</li>
              </ul>
            </div>
          </div>
        </div>
      </div>

      {/* Family Section */}
      <div className="py-16 bg-gray-50">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Made for our family
            </h2>
            <p className="text-lg text-gray-600">
              Each family member has their own color and personalized experience
            </p>
          </div>

          <div className="grid sm:grid-cols-2 lg:grid-cols-4 gap-6">
            {/* Family Members */}
            <div className="card text-center p-6">
              <div className="w-12 h-12 bg-family-gonzalo rounded-full mx-auto mb-4 flex items-center justify-center">
                <Users className="w-6 h-6 text-white" />
              </div>
              <h3 className="font-semibold text-family-gonzalo mb-2">Gonzalo</h3>
              <p className="text-sm text-gray-600">Blue theme</p>
            </div>

            <div className="card text-center p-6">
              <div className="w-12 h-12 bg-family-mariapaz rounded-full mx-auto mb-4 flex items-center justify-center">
                <Users className="w-6 h-6 text-white" />
              </div>
              <h3 className="font-semibold text-family-mariapaz mb-2">María Paz</h3>
              <p className="text-sm text-gray-600">Red theme</p>
            </div>

            <div className="card text-center p-6">
              <div className="w-12 h-12 bg-family-borja rounded-full mx-auto mb-4 flex items-center justify-center">
                <Users className="w-6 h-6 text-white" />
              </div>
              <h3 className="font-semibold text-family-borja mb-2">Borja</h3>
              <p className="text-sm text-gray-600">Green theme</p>
            </div>

            <div className="card text-center p-6">
              <div className="w-12 h-12 bg-family-melody rounded-full mx-auto mb-4 flex items-center justify-center">
                <Users className="w-6 h-6 text-white" />
              </div>
              <h3 className="font-semibold text-family-melody mb-2">Melody</h3>
              <p className="text-sm text-gray-600">Purple theme</p>
            </div>
          </div>
        </div>
      </div>

      {/* Technology Section */}
      <div className="py-16 bg-white">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center mb-12">
            <h2 className="text-3xl font-bold text-gray-900 mb-4">
              Built with modern technology
            </h2>
            <p className="text-lg text-gray-600">
              Cloud-first development with automatic testing and deployment
            </p>
          </div>

          <div className="grid md:grid-cols-2 gap-8 items-center">
            <div>
              <h3 className="text-2xl font-semibold text-gray-900 mb-6">Features</h3>
              <ul className="space-y-4">
                <li className="flex items-start gap-3">
                  <CheckCircle className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
                  <span className="text-gray-700">
                    <strong>Real-time sync</strong> - Changes appear instantly across all devices
                  </span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
                  <span className="text-gray-700">
                    <strong>Offline capable</strong> - Works without internet connection
                  </span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
                  <span className="text-gray-700">
                    <strong>Mobile optimized</strong> - Perfect experience on phones and tablets
                  </span>
                </li>
                <li className="flex items-start gap-3">
                  <CheckCircle className="w-5 h-5 text-green-500 mt-0.5 flex-shrink-0" />
                  <span className="text-gray-700">
                    <strong>Secure & private</strong> - Your family data is encrypted and protected
                  </span>
                </li>
              </ul>
            </div>
            
            <div className="bg-gray-900 rounded-lg p-6 text-green-400 font-mono text-sm">
              <div className="mb-2 text-gray-400"># Technology Stack</div>
              <div>🔸 Next.js 14 + TypeScript</div>
              <div>🔸 Supabase (Database + Auth)</div>
              <div>🔸 Tailwind CSS</div>
              <div>🔸 Framer Motion</div>
              <div>🔸 Vercel Deployment</div>
              <div>🔸 GitHub Actions CI/CD</div>
              <div className="mt-4 text-gray-400"># Development</div>
              <div>🔸 100% Cloud Development</div>
              <div>🔸 Automated Testing</div>
              <div>🔸 Preview Deployments</div>
            </div>
          </div>
        </div>
      </div>

      {/* Footer */}
      <footer className="bg-gray-900 text-white py-12">
        <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
          <div className="text-center">
            <h3 className="text-2xl font-bold mb-4">Family Hub</h3>
            <p className="text-gray-400 mb-6">
              Built with ❤️ for the Gonzalo family
            </p>
            <div className="flex justify-center gap-8">
              <Link href="/auth/signup" className="text-gray-400 hover:text-white transition-colors">
                Get Started
              </Link>
              <Link href="/auth/login" className="text-gray-400 hover:text-white transition-colors">
                Sign In
              </Link>
            </div>
            <div className="mt-8 pt-8 border-t border-gray-800 text-gray-500 text-sm">
              © 2024 Family Hub. Built with Next.js, Supabase, and Vercel.
            </div>
          </div>
        </div>
      </footer>
    </main>
  )
}