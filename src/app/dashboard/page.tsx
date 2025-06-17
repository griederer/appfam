export default function DashboardPage() {
  return (
    <div className="min-h-screen bg-background-main">
      <div className="max-w-7xl mx-auto px-4 py-8">
        <h1 className="text-3xl font-bold text-gray-900 mb-8">Family Hub Dashboard</h1>
        
        <div className="grid md:grid-cols-3 gap-6">
          <div className="card p-6">
            <h2 className="text-xl font-semibold mb-4">Today's Tasks</h2>
            <p className="text-gray-600">No tasks for today</p>
          </div>
          
          <div className="card p-6">
            <h2 className="text-xl font-semibold mb-4">Grocery List</h2>
            <p className="text-gray-600">Your grocery list is empty</p>
          </div>
          
          <div className="card p-6">
            <h2 className="text-xl font-semibold mb-4">Upcoming Events</h2>
            <p className="text-gray-600">No upcoming events</p>
          </div>
        </div>
      </div>
    </div>
  )
}