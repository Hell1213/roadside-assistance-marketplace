'use client';

import { useState } from 'react';
import Header from '@/components/Header';
import Sidebar from '@/components/Sidebar';

export default function UsersPage() {
  const [searchTerm, setSearchTerm] = useState('');
  const [statusFilter, setStatusFilter] = useState('all');

  const users = [
    { id: 'USR001', name: 'John Doe', email: 'john@example.com', phone: '+1234567890', status: 'Active', joinDate: '2024-01-15', totalTrips: 12 },
    { id: 'USR002', name: 'Sarah Smith', email: 'sarah@example.com', phone: '+1234567891', status: 'Active', joinDate: '2024-02-20', totalTrips: 8 },
    { id: 'USR003', name: 'Alex Johnson', email: 'alex@example.com', phone: '+1234567892', status: 'Inactive', joinDate: '2024-01-10', totalTrips: 3 },
    { id: 'USR004', name: 'Emily Chen', email: 'emily@example.com', phone: '+1234567893', status: 'Active', joinDate: '2024-03-05', totalTrips: 15 },
    { id: 'USR005', name: 'Michael Brown', email: 'michael@example.com', phone: '+1234567894', status: 'Suspended', joinDate: '2024-01-25', totalTrips: 2 },
  ];

  const filteredUsers = users.filter(user => {
    const matchesSearch = user.name.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.email.toLowerCase().includes(searchTerm.toLowerCase()) ||
                         user.phone.includes(searchTerm);
    const matchesStatus = statusFilter === 'all' || user.status.toLowerCase() === statusFilter;
    return matchesSearch && matchesStatus;
  });

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'Active': return 'bg-green-100 text-green-800';
      case 'Inactive': return 'bg-gray-100 text-gray-800';
      case 'Suspended': return 'bg-red-100 text-red-800';
      default: return 'bg-gray-100 text-gray-800';
    }
  };

  const handleUserAction = (userId: string, action: string) => {
    alert(`${action} user ${userId}`);
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        
        <main className="flex-1 overflow-y-auto p-6">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">User Management</h1>
            <p className="text-gray-600">Manage customer accounts and user data</p>
          </div>

          <div className="card mb-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <div className="flex-1 max-w-md">
                <input
                  type="text"
                  placeholder="Search users by name, email, or phone..."
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
                  <option value="inactive">Inactive</option>
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
                    <th className="text-left py-3 text-sm font-medium text-gray-600">User ID</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Name</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Email</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Phone</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Status</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Join Date</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Total Trips</th>
                    <th className="text-left py-3 text-sm font-medium text-gray-600">Actions</th>
                  </tr>
                </thead>
                <tbody>
                  {filteredUsers.map((user) => (
                    <tr key={user.id} className="border-b border-gray-100 hover:bg-gray-50">
                      <td className="py-4 text-sm font-medium text-gray-900">{user.id}</td>
                      <td className="py-4 text-sm text-gray-900">{user.name}</td>
                      <td className="py-4 text-sm text-gray-600">{user.email}</td>
                      <td className="py-4 text-sm text-gray-600">{user.phone}</td>
                      <td className="py-4">
                        <span className={`px-2 py-1 rounded-full text-xs font-medium ${getStatusColor(user.status)}`}>
                          {user.status}
                        </span>
                      </td>
                      <td className="py-4 text-sm text-gray-600">{user.joinDate}</td>
                      <td className="py-4 text-sm text-gray-600">{user.totalTrips}</td>
                      <td className="py-4">
                        <div className="flex items-center gap-2">
                          <button
                            onClick={() => handleUserAction(user.id, 'View')}
                            className="text-blue-600 hover:text-blue-800 text-sm font-medium"
                          >
                            View
                          </button>
                          <button
                            onClick={() => handleUserAction(user.id, 'Edit')}
                            className="text-yellow-600 hover:text-yellow-800 text-sm font-medium"
                          >
                            Edit
                          </button>
                          {user.status === 'Active' ? (
                            <button
                              onClick={() => handleUserAction(user.id, 'Suspend')}
                              className="text-red-600 hover:text-red-800 text-sm font-medium"
                            >
                              Suspend
                            </button>
                          ) : (
                            <button
                              onClick={() => handleUserAction(user.id, 'Activate')}
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
            
            {filteredUsers.length === 0 && (
              <div className="text-center py-8">
                <p className="text-gray-500">No users found matching your criteria</p>
              </div>
            )}
          </div>
        </main>
      </div>
    </div>
  );
}