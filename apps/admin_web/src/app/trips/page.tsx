'use client';

import { useState } from 'react';
import Header from '@/components/Header';
import Sidebar from '@/components/Sidebar';

export default function TripsPage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const trips = [
    { id: 'TRP001', customer: 'John Doe', driver: 'Mike Wilson', service: 'Tow Service', status: 'Completed', amount: '₹150', startTime: '2024-12-28 10:30', endTime: '2024-12-28 11:15', location: 'MG Road, Bangalore' },
    { id: 'TRP002', customer: 'Sarah Smith', driver: 'David Brown', service: 'Jump Start', status: 'In Progress', amount: '₹80', startTime: '2024-12-28 14:20', endTime: '-', location: 'Koramangala, Bangalore' },
    { id: 'TRP003', customer: 'Alex Johnson', driver: 'Tom Davis', service: 'Fuel Delivery', status: 'Assigned', amount: '₹120', startTime: '2024-12-28 15:45', endTime: '-', location: 'Whitefield, Bangalore' },
    { id: 'TRP004', customer: 'Emily Chen', driver: 'Chris Miller', service: 'Flat Tire', status: 'Completed', amount: '₹100', startTime: '2024-12-28 09:15', endTime: '2024-12-28 10:00', location: 'Indiranagar, Bangalore' },
    { id: 'TRP005', customer: 'Michael Brown', driver: 'James Wilson', service: 'Tow Service', status: 'Cancelled', amount: '₹0', startTime: '2024-12-28 12:00', endTime: '2024-12-28 12:05', location: 'HSR Layout, Bangalore' },
  ];

  const filteredTrips = trips.filter(trip => {
    const matchesSearch = trip.id.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         trip.customer.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         trip.driver.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         trip.service.toLowerCase().includes(searchTerm.toLowerCase());
    const matchesStatus = statusFilter === 'all' || trip.status.toLowerCase().replace(' ', '') === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Completed': return 'bg-green-100 text-green-800';
      case 'In Progress': return 'bg-blue-100 text-blue-800';
      case 'Assigned': return 'bg-yellow-100 text-yellow-800';
      case 'Cancelled': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const handleTripAction = (tripId: string, action: string) => {
    alert(`${action} trip ${tripId}`);
  };

  const totalRevenue = trips.filter(t => t.status === 'Completed').reduce((sum, trip) => sum + parseInt(trip.amount.replace('₹', '')), 0);
  const completedTrips = trips.filter(t => t.status === 'Completed').length;
  const activeTrips = trips.filter(t => t.status === 'In Progress' || t.status === 'Assigned').length;
  const cancelledTrips = trips.filter(t => t.status === 'Cancelled').length;

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        
        <main className="flex-1 overflow-y-auto p-6">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Trip Management</h1>
            <p className="text-gray-600">Monitor and manage all trip requests and completions</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Total Trips</p>
                  <p className="text-2xl font-bold text-gray-900">{trips.length}</p>
                </div>
                <span className="text-2xl">🗺️</span>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Completed</p>
                  <p className="text-2xl font-bold text-green-600">{completedTrips}</p>
                </div>
                <span className="text-2xl">✅</span>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Active</p>
                  <p className="text-2xl font-bold text-blue-600">{activeTrips}</p>
                </div>
                <span className="text-2xl">🚗</span>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Revenue</p>
                  <p className="text-2xl font-bold text-yellow-600">₹{totalRevenue}</p>
                </div>
                <span className="text-2xl">💰</span>
              </div>
            </div>
          </div>

          <div className="card mb-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <div className="flex-1 max-w-md">
                <input
                  type="text"
                  placeholder="Search trips by ID, customer, driver, or service..."
                  value={searchTerm}
                  onChange={(e) => setSearchTerm(e.target.value)}
                  className="w-full px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                />
              </div>
              
              <div className="flex items-center gap-4">
                <select
                  value={statusFilter}
                  onChange={(e) => setStatusFilter(e.target.value)}
                  className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                >
                  <option value="all">All Status</option>
                  <option value="completed">Completed</option>
                  <option value="inprogress">In Progress</option>
                  <option value="assigned">Assigned</option>
                  <option value="cancelled">Cancelled</option>
                </select>
                
                <button className="btn-primary">
                  Export Data
                </button>
              </div>
            </div>
          </div>

          <div className="card">
            <div className="overflow-x-auto">
              <table className="min-w-full">
                <thead>
                  <tr className="border-b border-gray-200">
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Trip ID</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Customer</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Driver</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Service</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Status</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Location</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Duration</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Amount</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredTrips.map((trip) => (
                    <tr key={trip.id} className="border-b border-gray-100 hover:bg-gray-50">
                      <td className="py-4 text-sm font-medium text-gray-900">{trip.id}</td>
                      <td className="py-4 text-sm text-gray-900">{trip.customer}</td>
                      <td className="py-4 text-sm text-gray-900">{trip.driver}</td>
                      <td className="py-4 text-sm text-gray-600">{trip.service}</td>
                      <td className="py-4">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(trip.status)}`}>
                          {trip.status}
                        </span>
                      </td>
                      <td className="py-4 text-sm text-gray-600">{trip.location}</td>
                      <td className="py-4 text-sm text-gray-600">
                        <div>
                          <div className="text-xs">Start: {trip.startTime.split(' ')[1]}</div>
                          <div className="text-xs">End: {trip.endTime === '-' ? 'Ongoing' : trip.endTime.split(' ')[1]}</div>
                        </div>
                      </td>
                      <td className="py-4 text-sm font-medium text-gray-900">{trip.amount}</td>
                      <td className="py-4">
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => handleTripAction(trip.id, 'View Details')}
                            className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                          >
                            View
                          </button>
                          <button
                            onClick={() => handleTripAction(trip.id, 'Track')}
                            className="text-yellow-600 hover:text-yellow-800 text-sm font-medium"
                          >
                            Track
                          </button>
                          {trip.status === 'In Progress' && (
                            <button
                              onClick={() => handleTripAction(trip.id, 'Intervene')}
                              className="text-red-600 hover:text-red-800 text-sm font-medium"
                            >
                              Intervene
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            
            {filteredTrips.length === 0 && (
              <div className="text-center py-8">
                <p className="text-gray-500">No trips found matching your criteria</p>
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  );
}