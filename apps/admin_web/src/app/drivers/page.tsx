'use client';

import { useState } from 'react';
import Header from '@/components/Header';
import Sidebar from '@/components/Sidebar';

export default function DriversPage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const drivers = [
    { id: 'DRV001', name: 'Mike Wilson', email: 'mike@example.com', phone: '+1234567890', status: 'Active', kycStatus: 'Verified', rating: 4.8, totalTrips: 156, earnings: '₹12,450' },
    { id: 'DRV002', name: 'David Brown', email: 'david@example.com', phone: '+1234567891', status: 'Active', kycStatus: 'Pending', rating: 4.6, totalTrips: 89, earnings: '₹8,920' },
    { id: 'DRV003', name: 'Tom Davis', email: 'tom@example.com', phone: '+1234567892', status: 'Offline', kycStatus: 'Verified', rating: 4.9, totalTrips: 203, earnings: '₹18,750' },
    { id: 'DRV004', name: 'Chris Miller', email: 'chris@example.com', phone: '+1234567893', status: 'Active', kycStatus: 'Rejected', rating: 4.2, totalTrips: 45, earnings: '₹3,680' },
    { id: 'DRV005', name: 'James Wilson', email: 'james@example.com', phone: '+1234567894', status: 'Suspended', kycStatus: 'Verified', rating: 3.8, totalTrips: 23, earnings: '₹1,890' },
  ];

  const filteredDrivers = drivers.filter(driver => {
    const matchesSearch = driver.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         driver.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         driver.phone.includes(searchTerm);
    const matchesStatus = statusFilter === 'all' || driver.status.toLowerCase() === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Active': return 'bg-green-100 text-green-800';
      case 'Offline': return 'bg-gray-100 text-gray-800';
      case 'Suspended': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const getKycStatusColor = (status: string) => {
    switch (status) {
      case 'Verified': return 'bg-green-100 text-green-800';
      case 'Pending': return 'bg-yellow-100 text-yellow-800';
      case 'Rejected': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const handleDriverAction = (driverId: string, action: string) => {
    alert(`${action} driver ${driverId}`);
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        
        <main className="flex-1 overflow-y-auto p-6">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Driver Management</h1>
            <p className="text-gray-600">Manage driver accounts, KYC verification, and performance</p>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-4 gap-4 mb-6">
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Total Drivers</p>
                  <p className="text-2xl font-bold text-gray-900">{drivers.length}</p>
                </div>
                <span className="text-2xl">🚗</span>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Active Now</p>
                  <p className="text-2xl font-bold text-green-600">{drivers.filter(d => d.status === 'Active').length}</p>
                </div>
                <span className="text-2xl">✅</span>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">KYC Pending</p>
                  <p className="text-2xl font-bold text-yellow-600">{drivers.filter(d => d.kycStatus === 'Pending').length}</p>
                </div>
                <span className="text-2xl">⏳</span>
              </div>
            </div>
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Avg Rating</p>
                  <p className="text-2xl font-bold text-yellow-600">4.7</p>
                </div>
                <span className="text-2xl">⭐</span>
              </div>
            </div>
          </div>

          <div className="card mb-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <div className="flex-1 max-w-md">
                <input
                  type="text"
                  placeholder="Search drivers by name, email, or phone..."
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
                  <option value="active">Active</option>
                  <option value="offline">Offline</option>
                  <option value="suspended">Suspended</option>
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
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Driver ID</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Name</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Contact</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Status</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">KYC Status</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Rating</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Trips</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Earnings</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredDrivers.map((driver) => (
                    <tr key={driver.id} className="border-b border-gray-100 hover:bg-gray-50">
                      <td className="py-4 text-sm font-medium text-gray-900">{driver.id}</td>
                      <td className="py-4 text-sm text-gray-900">{driver.name}</td>
                      <td className="py-4 text-sm text-gray-600">
                        <div>
                          <div>{driver.email}</div>
                          <div className="text-xs text-gray-500">{driver.phone}</div>
                        </div>
                      </td>
                      <td className="py-4">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(driver.status)}`}>
                          {driver.status}
                        </span>
                      </td>
                      <td className="py-4">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getKycStatusColor(driver.kycStatus)}`}>
                          {driver.kycStatus}
                        </span>
                      </td>
                      <td className="py-4 text-sm text-gray-600">
                        <div className="flex items-center">
                          <span className="text-yellow-400 mr-1">⭐</span>
                          {driver.rating}
                        </div>
                      </td>
                      <td className="py-4 text-sm text-gray-600">{driver.totalTrips}</td>
                      <td className="py-4 text-sm font-medium text-gray-900">{driver.earnings}</td>
                      <td className="py-4">
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => handleDriverAction(driver.id, 'View')}
                            className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                          >
                            View
                          </button>
                          {driver.kycStatus === 'Pending' && (
                            <button
                              onClick={() => handleDriverAction(driver.id, 'Verify KYC')}
                              className="text-green-600 hover:text-green-800 text-sm font-medium"
                            >
                              Verify
                            </button>
                          )}
                          {driver.status === 'Active' ? (
                            <button
                              onClick={() => handleDriverAction(driver.id, 'Suspend')}
                              className="text-red-600 hover:text-red-800 text-sm font-medium"
                            >
                              Suspend
                            </button>
                          ) : (
                            <button
                              onClick={() => handleDriverAction(driver.id, 'Activate')}
                              className="text-green-600 hover:text-green-800 text-sm font-medium"
                            >
                              Activate
                            </button>
                          )}
                        </div>
                      </td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
            
            {filteredDrivers.length === 0 && (
              <div className="text-center py-8">
                <p className="text-gray-500">No drivers found matching your criteria</p>
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  );
}