import Header from '@/components/Header';
import Sidebar from '@/components/Sidebar';

export default function Home() {
  const stats = [
    { name: 'Total Users', value: '2,847', change: '+12%', icon: '👥' },
    { name: 'Active Drivers', value: '156', change: '+8%', icon: '🚗' },
    { name: 'Today\'s Trips', value: '89', change: '+23%', icon: '🗺️' },
    { name: 'Revenue', value: '₹45,230', change: '+15%', icon: '💰' },
  ];

  const recentTrips = [
    { id: 'TRP001', customer: 'John Doe', driver: 'Mike Wilson', service: 'Tow Service', status: 'Completed', amount: '₹150' },
    { id: 'TRP002', customer: 'Sarah Smith', driver: 'David Brown', service: 'Jump Start', status: 'In Progress', amount: '₹80' },
    { id: 'TRP003', customer: 'Alex Johnson', driver: 'Tom Davis', service: 'Fuel Delivery', status: 'Assigned', amount: '₹120' },
    { id: 'TRP004', customer: 'Emily Chen', driver: 'Chris Miller', service: 'Flat Tire', status: 'Completed', amount: '₹100' },
  ];

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Completed': return 'bg-green-100 text-green-800';
      case 'In Progress': return 'bg-blue-100 text-blue-800';
      case 'Assigned': return 'bg-yellow-100 text-yellow-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        
        <main className="flex-1 overflow-y-auto p-6">
          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            {stats.map((stat) => (
              <div key={stat.name} className="stat-card">
                <div className="flex items-center justify-between">
                  <div>
                    <p className="text-sm font-medium text-gray-600">{stat.name}</p>
                    <p className="text-2xl font-bold text-gray-900">{stat.value}</p>
                  </div>
                  <div className="text-2xl">{stat.icon}</div>
                </div>
                <div className="mt-2">
                  <span className="text-sm font-medium text-green-600">{stat.change}</span>
                  <span className="text-sm text-gray-600"> from last month</span>
                </div>
              </div>
            ))}
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Trips</h3>
              <div className="overflow-x-auto">
                <table className="min-w-full">
                  <thead>
                    <tr className="border-b border-gray-200">
                      <th className="text-left py-2 text-sm font-medium text-gray-600">Trip ID</th>
                      <th className="text-left py-2 text-sm font-medium text-gray-600">Customer</th>
                      <th className="text-left py-2 text-sm font-medium text-gray-600">Service</th>
                      <th className="text-left py-2 text-sm font-medium text-gray-600">Status</th>
                      <th className="text-left py-2 text-sm font-medium text-gray-600">Amount</th>
                    </tr>
                  </thead>
                  <tbody>
                    {recentTrips.map((trip) => (
                      <tr key={trip.id} className="border-b border-gray-100">
                        <td className="py-3 text-sm font-medium text-gray-900">{trip.id}</td>
                        <td className="py-3 text-sm text-gray-600">{trip.customer}</td>
                        <td className="py-3 text-sm text-gray-600">{trip.service}</td>
                        <td className="py-3">
                          <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(trip.status)}`}>
                            {trip.status}
                          </span>
                        </td>
                        <td className="py-3 text-sm font-medium text-gray-900">{trip.amount}</td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Quick Actions</h3>
              <div className="space-y-3">
                <button className="w-full btn-primary text-left">
                  <span className="mr-2">👥</span>
                  Manage Users
                </button>
                <button className="w-full btn-secondary text-left">
                  <span className="mr-2">🚗</span>
                  Verify Drivers
                </button>
                <button className="w-full bg-green-600 hover:bg-green-700 text-white font-medium px-4 py-2 rounded-lg transition-colors text-left">
                  <span className="mr-2">💰</span>
                  Update Pricing
                </button>
                <button className="w-full bg-blue-600 hover:bg-blue-700 text-white font-medium px-4 py-2 rounded-lg transition-colors text-left">
                  <span className="mr-2">📈</span>
                  View Reports
                </button>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}
