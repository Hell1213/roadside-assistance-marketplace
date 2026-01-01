'use client';

import { useState } from 'react';
import Header from '@/components/Header';
import Sidebar from '@/components/Sidebar';

export default function ReportsPage() {
  const [dateRange, setDateRange] = useState('7days');
  const [reportType, setReportType] = useState('revenue');

  const revenueData = {
    totalRevenue: 145230,
    totalCommission: 26142,
    totalTrips: 342,
    avgTripValue: 425,
    growth: 15.2
  };

  const driverData = {
    totalDrivers: 156,
    activeDrivers: 89,
    newDrivers: 12,
    avgRating: 4.7,
    topPerformer: 'Mike Wilson'
  };

  const serviceData = [
    { service: 'Tow Service', trips: 145, revenue: 65200, avgRating: 4.8 },
    { service: 'Jump Start', trips: 89, revenue: 28450, avgRating: 4.6 },
    { service: 'Fuel Delivery', trips: 67, revenue: 32100, avgRating: 4.9 },
    { service: 'Flat Tire', trips: 41, revenue: 19480, avgRating: 4.5 },
  ];

  const topDrivers = [
    { name: 'Mike Wilson', trips: 45, revenue: 12450, rating: 4.9 },
    { name: 'Tom Davis', trips: 38, revenue: 11200, rating: 4.8 },
    { name: 'David Brown', trips: 32, revenue: 9800, rating: 4.7 },
    { name: 'Chris Miller', trips: 28, revenue: 8650, rating: 4.6 },
  ];

  const recentActivity = [
    { time: '2 mins ago', event: 'New trip completed', details: 'TRP001 - ₹150' },
    { time: '5 mins ago', event: 'Driver went online', details: 'Mike Wilson - Koramangala' },
    { time: '12 mins ago', event: 'Payment processed', details: 'TRP002 - ₹80' },
    { time: '18 mins ago', event: 'New user registered', details: 'Sarah Smith' },
    { time: '25 mins ago', event: 'Trip cancelled', details: 'TRP003 - Customer request' },
  ];

  const handleExport = (type: string) => {
    alert(`Exporting ${type} report for ${dateRange}`);
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        
        <main className="flex-1 overflow-y-auto p-6">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Reports & Analytics</h1>
            <p className="text-gray-600">Comprehensive insights into platform performance</p>
          </div>

          <div className="card mb-6">
            <div className="flex flex-col md:flex-row md:items-center md:justify-between gap-4">
              <div className="flex items-center gap-4">
                <select
                  value={dateRange}
                  onChange={(e) => setDateRange(e.target.value)}
                  className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                >
                  <option value="today">Today</option>
                  <option value="7days">Last 7 Days</option>
                  <option value="30days">Last 30 Days</option>
                  <option value="90days">Last 90 Days</option>
                  <option value="custom">Custom Range</option>
                </select>
                
                <select
                  value={reportType}
                  onChange={(e) => setReportType(e.target.value)}
                  className="px-4 py-2 border border-gray-300 rounded-lg focus:ring-2 focus:ring-yellow-500 focus:border-transparent"
                >
                  <option value="revenue">Revenue Report</option>
                  <option value="driver">Driver Performance</option>
                  <option value="service">Service Analytics</option>
                  <option value="customer">Customer Insights</option>
                </select>
              </div>
              
              <div className="flex items-center gap-2">
                <button
                  onClick={() => handleExport('PDF')}
                  className="btn-secondary text-sm"
                >
                  Export PDF
                </button>
                <button
                  onClick={() => handleExport('Excel')}
                  className="btn-primary text-sm"
                >
                  Export Excel
                </button>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6 mb-8">
            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Total Revenue</p>
                  <p className="text-2xl font-bold text-gray-900">₹{revenueData.totalRevenue.toLocaleString()}</p>
                </div>
                <span className="text-2xl">💰</span>
              </div>
              <div className="mt-2">
                <span className="text-sm font-medium text-green-600">+{revenueData.growth}%</span>
                <span className="text-sm text-gray-600"> vs last period</span>
              </div>
            </div>

            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Commission Earned</p>
                  <p className="text-2xl font-bold text-gray-900">₹{revenueData.totalCommission.toLocaleString()}</p>
                </div>
                <span className="text-2xl">📈</span>
              </div>
              <div className="mt-2">
                <span className="text-sm text-gray-600">18% avg rate</span>
              </div>
            </div>

            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Total Trips</p>
                  <p className="text-2xl font-bold text-gray-900">{revenueData.totalTrips}</p>
                </div>
                <span className="text-2xl">🗺️</span>
              </div>
              <div className="mt-2">
                <span className="text-sm text-gray-600">₹{revenueData.avgTripValue} avg value</span>
              </div>
            </div>

            <div className="stat-card">
              <div className="flex items-center justify-between">
                <div>
                  <p className="text-sm font-medium text-gray-600">Active Drivers</p>
                  <p className="text-2xl font-bold text-gray-900">{driverData.activeDrivers}</p>
                </div>
                <span className="text-2xl">🚗</span>
              </div>
              <div className="mt-2">
                <span className="text-sm text-gray-600">of {driverData.totalDrivers} total</span>
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6 mb-6">
            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Service Performance</h3>
              <div className="overflow-x-auto">
                <table className="min-w-full">
                  <thead>
                    <tr className="border-b border-gray-200">
                      <th className="text-left py-2 text-sm font-medium text-gray-600">Service</th>
                      <th className="text-left py-2 text-sm font-medium text-gray-600">Trips</th>
                      <th className="text-left py-2 text-sm font-medium text-gray-600">Revenue</th>
                      <th className="text-left py-2 text-sm font-medium text-gray-600">Rating</th>
                    </tr>
                  </thead>
                  <tbody>
                    {serviceData.map((service) => (
                      <tr key={service.service} className="border-b border-gray-100">
                        <td className="py-3 text-sm font-medium text-gray-900">{service.service}</td>
                        <td className="py-3 text-sm text-gray-600">{service.trips}</td>
                        <td className="py-3 text-sm text-gray-600">₹{service.revenue.toLocaleString()}</td>
                        <td className="py-3 text-sm text-gray-600">
                          <div className="flex items-center">
                            <span className="text-yellow-400 mr-1">⭐</span>
                            {service.avgRating}
                          </div>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            </div>

            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Top Performing Drivers</h3>
              <div className="space-y-3">
                {topDrivers.map((driver, index) => (
                  <div key={driver.name} className="flex items-center justify-between py-2 border-b border-gray-100">
                    <div className="flex items-center">
                      <div className="w-8 h-8 bg-yellow-400 rounded-full flex items-center justify-center mr-3">
                        <span className="text-sm font-medium">{index + 1}</span>
                      </div>
                      <div>
                        <p className="text-sm font-medium text-gray-900">{driver.name}</p>
                        <p className="text-xs text-gray-600">{driver.trips} trips</p>
                      </div>
                    </div>
                    <div className="text-right">
                      <p className="text-sm font-medium text-gray-900">₹{driver.revenue.toLocaleString()}</p>
                      <div className="flex items-center">
                        <span className="text-yellow-400 mr-1">⭐</span>
                        <span className="text-xs text-gray-600">{driver.rating}</span>
                      </div>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
            <div className="lg:col-span-2 card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Revenue Trend</h3>
              <div className="h-64 bg-gray-100 rounded-lg flex items-center justify-center">
                <p className="text-gray-500">Revenue chart visualization would go here</p>
              </div>
            </div>

            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Recent Activity</h3>
              <div className="space-y-3">
                {recentActivity.map((activity, index) => (
                  <div key={index} className="flex items-start space-x-3">
                    <div className="w-2 h-2 bg-yellow-400 rounded-full mt-2"></div>
                    <div className="flex-1">
                      <p className="text-sm font-medium text-gray-900">{activity.event}</p>
                      <p className="text-xs text-gray-600">{activity.details}</p>
                      <p className="text-xs text-gray-500">{activity.time}</p>
                    </div>
                  </div>
                ))}
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}