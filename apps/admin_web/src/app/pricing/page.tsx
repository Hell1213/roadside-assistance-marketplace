'use client';

import { useState } from 'react';
import Header from '@/components/Header';
import Sidebar from '@/components/Sidebar';

export default function PricingPage() {
  const [activeTab, setActiveTab] = useState('base-rates');

  const baseRates = [
    { service: 'Tow Service', baseFare: 100, perKmRate: 15, timeRate: 2, minCharge: 150 },
    { service: 'Jump Start', baseFare: 50, perKmRate: 10, timeRate: 1.5, minCharge: 80 },
    { service: 'Fuel Delivery', baseFare: 60, perKmRate: 12, timeRate: 2, minCharge: 100 },
    { service: 'Flat Tire', baseFare: 70, perKmRate: 8, timeRate: 1, minCharge: 90 },
  ];

  const commissionRates = [
    { category: 'New Drivers (0-50 trips)', rate: 15, description: 'Lower commission for new drivers' },
    { category: 'Regular Drivers (51-200 trips)', rate: 20, description: 'Standard commission rate' },
    { category: 'Premium Drivers (200+ trips)', rate: 18, description: 'Reduced rate for high-volume drivers' },
  ];

  const surgeRules = [
    { condition: 'Peak Hours (8-10 AM, 6-8 PM)', multiplier: 1.5, status: 'Active' },
    { condition: 'High Demand Areas', multiplier: 1.3, status: 'Active' },
    { condition: 'Weather Conditions (Rain/Storm)', multiplier: 2.0, status: 'Inactive' },
    { condition: 'Festival/Holiday Periods', multiplier: 1.8, status: 'Inactive' },
  ];

  const handleRateUpdate = (service: string, field: string, value: number) => {
    alert(`Update ${service} ${field} to ₹${value}`);
  };

  const handleCommissionUpdate = (category: string, rate: number) => {
    alert(`Update commission for ${category} to ${rate}%`);
  };

  const handleSurgeToggle = (condition: string) => {
    alert(`Toggle surge pricing for ${condition}`);
  };

  return (
    <div className="flex h-screen bg-gray-50">
      <Sidebar />
      
      <div className="flex-1 flex flex-col overflow-hidden">
        <Header />
        
        <main className="flex-1 overflow-y-auto p-6">
          <div className="mb-6">
            <h1 className="text-2xl font-bold text-gray-900 mb-2">Pricing Configuration</h1>
            <p className="text-gray-600">Manage service rates, commissions, and surge pricing</p>
          </div>

          <div className="card mb-6">
            <div className="flex border-b border-gray-200">
              <button
                onClick={() => setActiveTab('base-rates')}
                className={`px-6 py-3 text-sm font-medium ${
                  activeTab === 'base-rates'
                    ? 'border-b-2 border-yellow-500 text-yellow-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                Base Rates
              </button>
              <button
                onClick={() => setActiveTab('commission')}
                className={`px-6 py-3 text-sm font-medium ${
                  activeTab === 'commission'
                    ? 'border-b-2 border-yellow-500 text-yellow-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                Commission
              </button>
              <button
                onClick={() => setActiveTab('surge')}
                className={`px-6 py-3 text-sm font-medium ${
                  activeTab === 'surge'
                    ? 'border-b-2 border-yellow-500 text-yellow-600'
                    : 'text-gray-500 hover:text-gray-700'
                }`}
              >
                Surge Pricing
              </button>
            </div>

            <div className="p-6">
              {activeTab === 'base-rates' && (
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Service Base Rates</h3>
                  <div className="overflow-x-auto">
                    <table className="min-w-full">
                      <thead>
                        <tr className="border-b border-gray-200">
                          <th className="text-left py-3 text-sm font-medium text-gray-600">Service Type</th>
                          <th className="text-left py-3 text-sm font-medium text-gray-600">Base Fare (₹)</th>
                          <th className="text-left py-3 text-sm font-medium text-gray-600">Per KM (₹)</th>
                          <th className="text-left py-3 text-sm font-medium text-gray-600">Per Min (₹)</th>
                          <th className="text-left py-3 text-sm font-medium text-gray-600">Min Charge (₹)</th>
                          <th className="text-left py-3 text-sm font-medium text-gray-600">Actions</th>
                        </tr>
                      </thead>
                      <tbody>
                        {baseRates.map((rate) => (
                          <tr key={rate.service} className="border-b border-gray-100">
                            <td className="py-4 text-sm font-medium text-gray-900">{rate.service}</td>
                            <td className="py-4">
                              <input
                                type="number"
                                defaultValue={rate.baseFare}
                                className="w-20 px-2 py-1 border border-gray-300 rounded text-sm"
                                onChange={(e) => handleRateUpdate(rate.service, 'baseFare', parseInt(e.target.value))}
                              />
                            </td>
                            <td className="py-4">
                              <input
                                type="number"
                                defaultValue={rate.perKmRate}
                                className="w-20 px-2 py-1 border border-gray-300 rounded text-sm"
                                onChange={(e) => handleRateUpdate(rate.service, 'perKmRate', parseInt(e.target.value))}
                              />
                            </td>
                            <td className="py-4">
                              <input
                                type="number"
                                step="0.1"
                                defaultValue={rate.timeRate}
                                className="w-20 px-2 py-1 border border-gray-300 rounded text-sm"
                                onChange={(e) => handleRateUpdate(rate.service, 'timeRate', parseFloat(e.target.value))}
                              />
                            </td>
                            <td className="py-4">
                              <input
                                type="number"
                                defaultValue={rate.minCharge}
                                className="w-20 px-2 py-1 border border-gray-300 rounded text-sm"
                                onChange={(e) => handleRateUpdate(rate.service, 'minCharge', parseInt(e.target.value))}
                              />
                            </td>
                            <td className="py-4">
                              <button className="text-blue-600 hover:text-blue-800 text-sm font-medium">
                                Update
                              </button>
                            </td>
                          </tr>
                        ))}
                      </tbody>
                    </table>
                  </div>
                </div>
              )}

              {activeTab === 'commission' && (
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Commission Structure</h3>
                  <div className="space-y-4">
                    {commissionRates.map((commission) => (
                      <div key={commission.category} className="border border-gray-200 rounded-lg p-4">
                        <div className="flex items-center justify-between">
                          <div>
                            <h4 className="font-medium text-gray-900">{commission.category}</h4>
                            <p className="text-sm text-gray-600">{commission.description}</p>
                          </div>
                          <div className="flex items-center gap-4">
                            <div className="flex items-center gap-2">
                              <input
                                type="number"
                                defaultValue={commission.rate}
                                className="w-16 px-2 py-1 border border-gray-300 rounded text-sm"
                                onChange={(e) => handleCommissionUpdate(commission.category, parseInt(e.target.value))}
                              />
                              <span className="text-sm text-gray-600">%</span>
                            </div>
                            <button className="btn-primary text-sm">
                              Update
                            </button>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}

              {activeTab === 'surge' && (
                <div>
                  <h3 className="text-lg font-semibold text-gray-900 mb-4">Surge Pricing Rules</h3>
                  <div className="space-y-4">
                    {surgeRules.map((rule) => (
                      <div key={rule.condition} className="border border-gray-200 rounded-lg p-4">
                        <div className="flex items-center justify-between">
                          <div>
                            <h4 className="font-medium text-gray-900">{rule.condition}</h4>
                            <p className="text-sm text-gray-600">Multiplier: {rule.multiplier}x</p>
                          </div>
                          <div className="flex items-center gap-4">
                            <span className={`px-2 py-1 rounded-full text-xs font-medium ${
                              rule.status === 'Active' 
                                ? 'bg-green-100 text-green-800' 
                                : 'bg-gray-100 text-gray-800'
                            }`}>
                              {rule.status}
                            </span>
                            <button
                              onClick={() => handleSurgeToggle(rule.condition)}
                              className={`px-4 py-2 rounded-lg text-sm font-medium transition-colors ${
                                rule.status === 'Active'
                                  ? 'bg-red-600 hover:bg-red-700 text-white'
                                  : 'bg-green-600 hover:bg-green-700 text-white'
                              }`}
                            >
                              {rule.status === 'Active' ? 'Disable' : 'Enable'}
                            </button>
                          </div>
                        </div>
                      </div>
                    ))}
                  </div>
                </div>
              )}
            </div>
          </div>

          <div className="grid grid-cols-1 lg:grid-cols-2 gap-6">
            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Pricing History</h3>
              <div className="space-y-3">
                <div className="flex justify-between items-center py-2 border-b border-gray-100">
                  <div>
                    <p className="text-sm font-medium text-gray-900">Tow Service Base Rate</p>
                    <p className="text-xs text-gray-600">Updated 2 hours ago</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-gray-600">₹90 → ₹100</p>
                  </div>
                </div>
                <div className="flex justify-between items-center py-2 border-b border-gray-100">
                  <div>
                    <p className="text-sm font-medium text-gray-900">Commission Rate - New Drivers</p>
                    <p className="text-xs text-gray-600">Updated yesterday</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-gray-600">18% → 15%</p>
                  </div>
                </div>
                <div className="flex justify-between items-center py-2">
                  <div>
                    <p className="text-sm font-medium text-gray-900">Peak Hours Surge</p>
                    <p className="text-xs text-gray-600">Updated 3 days ago</p>
                  </div>
                  <div className="text-right">
                    <p className="text-sm text-gray-600">1.3x → 1.5x</p>
                  </div>
                </div>
              </div>
            </div>

            <div className="card">
              <h3 className="text-lg font-semibold text-gray-900 mb-4">Revenue Impact</h3>
              <div className="space-y-4">
                <div className="bg-green-50 border border-green-200 rounded-lg p-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-green-800">Today's Revenue</p>
                      <p className="text-2xl font-bold text-green-900">₹45,230</p>
                    </div>
                    <span className="text-green-600 text-sm">+15% vs yesterday</span>
                  </div>
                </div>
                <div className="bg-blue-50 border border-blue-200 rounded-lg p-4">
                  <div className="flex items-center justify-between">
                    <div>
                      <p className="text-sm font-medium text-blue-800">Commission Earned</p>
                      <p className="text-2xl font-bold text-blue-900">₹8,142</p>
                    </div>
                    <span className="text-blue-600 text-sm">18% avg rate</span>
                  </div>
                </div>
              </div>
            </div>
          </div>
        </main>
      </div>
    </div>
  );
}