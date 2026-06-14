'use client';

import React, { useState, useTransition } from 'react';
import { Store, User, Phone, Plus, Trash2, Pause, Play, X, AlertTriangle, Loader2, Edit } from 'lucide-react';
import { addShop, deleteShop, togglePauseShop, updateShop } from './actions';

interface Shop {
  id: string;
  name: string;
  owner_name: string;
  phone: string;
  subscription_ends_at: string;
  created_at?: string;
}

interface ShopsListClientProps {
  initialShops: Shop[];
}

export default function ShopsListClient({ initialShops }: ShopsListClientProps) {
  const [isAddOpen, setIsAddOpen] = useState(false);
  const [editingShop, setEditingShop] = useState<Shop | null>(null);
  const [deleteConfirmId, setDeleteConfirmId] = useState<string | null>(null);
  const [isPending, startTransition] = useTransition();
  const [errorMessage, setErrorMessage] = useState<string | null>(null);

  // Add Form State
  const [name, setName] = useState('');
  const [ownerName, setOwnerName] = useState('');
  const [phone, setPhone] = useState('');
  const [password, setPassword] = useState('');
  const [planYears, setPlanYears] = useState('1');

  // Edit Form State
  const [editName, setEditName] = useState('');
  const [editOwnerName, setEditOwnerName] = useState('');
  const [editPhone, setEditPhone] = useState('');
  const [editPassword, setEditPassword] = useState('');

  const handleAddShop = async (e: React.FormEvent) => {
    e.preventDefault();
    setErrorMessage(null);

    const formData = new FormData();
    formData.append('name', name);
    formData.append('owner_name', ownerName);
    formData.append('phone', phone);
    formData.append('password', password);
    formData.append('plan_years', planYears);

    startTransition(async () => {
      try {
        await addShop(formData);
        setIsAddOpen(false);
        setName('');
        setOwnerName('');
        setPhone('');
        setPassword('');
        setPlanYears('1');
      } catch (err: any) {
        setErrorMessage(err.message || 'Failed to add shop.');
      }
    });
  };

  const handleEditShop = async (e: React.FormEvent) => {
    e.preventDefault();
    if (!editingShop) return;
    setErrorMessage(null);

    const formData = new FormData();
    formData.append('name', editName);
    formData.append('owner_name', editOwnerName);
    formData.append('phone', editPhone);
    formData.append('password', editPassword);

    startTransition(async () => {
      try {
        await updateShop(editingShop.id, formData);
        setEditingShop(null);
        setEditPassword('');
      } catch (err: any) {
        setErrorMessage(err.message || 'Failed to update shop.');
      }
    });
  };

  const openEditModal = (shop: Shop) => {
    setEditingShop(shop);
    setEditName(shop.name);
    setEditOwnerName(shop.owner_name);
    setEditPhone(shop.phone);
    setEditPassword('');
  };

  const handleDelete = (id: string) => {
    setErrorMessage(null);
    startTransition(async () => {
      try {
        await deleteShop(id);
        setDeleteConfirmId(null);
      } catch (err: any) {
        setErrorMessage(err.message || 'Failed to delete shop.');
      }
    });
  };

  const handleTogglePause = (id: string, isPaused: boolean) => {
    setErrorMessage(null);
    startTransition(async () => {
      try {
        await togglePauseShop(id, isPaused);
      } catch (err: any) {
        setErrorMessage(err.message || 'Failed to update shop status.');
      }
    });
  };

  return (
    <div className="space-y-6">
      {errorMessage && (
        <div className="rounded-lg bg-red-50 p-4 border border-red-100 flex items-center text-red-800 text-sm font-medium">
          <AlertTriangle className="h-5 w-5 text-red-500 mr-2 flex-shrink-0" />
          {errorMessage}
        </div>
      )}

      {/* Header and Add Button */}
      <div className="flex items-center justify-between flex-wrap gap-4">
        <div>
          <h1 className="text-2xl font-semibold text-gray-900 flex items-center">
            <Store className="mr-3 h-6 w-6 text-gray-500" />
            Platform Shops
          </h1>
          <p className="mt-1 text-sm text-gray-500">
            Create, pause, or remove tailor stores registered on DarziPro.
          </p>
        </div>
        <button
          onClick={() => setIsAddOpen(true)}
          className="inline-flex items-center justify-center rounded-lg bg-gray-900 px-4 py-2.5 text-sm font-medium text-white hover:bg-black transition-colors shadow-sm"
        >
          <Plus className="mr-2 h-4 w-4" />
          Add Shop
        </button>
      </div>

      {/* Empty State */}
      {initialShops.length === 0 && (
        <div className="text-center py-16 bg-white border border-gray-200 rounded-xl shadow-sm">
          <Store className="mx-auto h-12 w-12 text-gray-300" />
          <h3 className="mt-2 text-sm font-semibold text-gray-900">No shops found</h3>
          <p className="mt-1 text-sm text-gray-500">
            Create a shop or verify your SUPABASE_SERVICE_ROLE_KEY to load data.
          </p>
        </div>
      )}

      {/* Table / Grid */}
      {initialShops.length > 0 && (
        <div className="bg-white shadow-sm rounded-xl border border-gray-200 overflow-hidden">
          <div className="overflow-x-auto">
            <table className="min-w-full divide-y divide-gray-200 text-left">
              <thead className="bg-gray-50">
                <tr>
                  <th scope="col" className="py-4 pl-6 pr-3 text-xs font-semibold uppercase tracking-wide text-gray-500">Shop Name</th>
                  <th scope="col" className="px-3 py-4 text-xs font-semibold uppercase tracking-wide text-gray-500">Owner & Phone</th>
                  <th scope="col" className="px-3 py-4 text-xs font-semibold uppercase tracking-wide text-gray-500">Status</th>
                  <th scope="col" className="px-3 py-4 text-xs font-semibold uppercase tracking-wide text-gray-500">Subscription Ends</th>
                  <th scope="col" className="relative py-4 pl-3 pr-6 text-right">
                    <span className="sr-only">Actions</span>
                  </th>
                </tr>
              </thead>
              <tbody className="divide-y divide-gray-100 bg-white">
                {initialShops.map((shop) => {
                  const isExpired = new Date(shop.subscription_ends_at) < new Date();
                  return (
                    <tr key={shop.id} className="hover:bg-gray-50/50 transition-colors">
                      <td className="whitespace-nowrap py-4 pl-6 pr-3">
                        <div className="font-semibold text-gray-900">{shop.name}</div>
                        <div className="text-xs text-gray-400 mt-0.5">ID: {shop.id.slice(0, 8)}...</div>
                      </td>
                      <td className="whitespace-nowrap px-3 py-4">
                        <div className="flex items-center text-sm text-gray-900">
                          <User className="mr-1.5 h-3.5 w-3.5 text-gray-400" />
                          {shop.owner_name}
                        </div>
                        <div className="flex items-center text-xs text-gray-500 mt-1">
                          <Phone className="mr-1.5 h-3.5 w-3.5 text-gray-400" />
                          {shop.phone}
                        </div>
                      </td>
                      <td className="whitespace-nowrap px-3 py-4">
                        <span className={`inline-flex items-center rounded-full px-2.5 py-0.5 text-xs font-medium ${isExpired ? 'bg-amber-50 text-amber-800 border border-amber-200' : 'bg-green-50 text-green-800 border border-green-200'}`}>
                          {isExpired ? 'Paused / Expired' : 'Active'}
                        </span>
                      </td>
                      <td className="whitespace-nowrap px-3 py-4 text-sm text-gray-600 font-medium">
                        {new Date(shop.subscription_ends_at) < new Date(10000) ? 'Never / Paused' : new Date(shop.subscription_ends_at).toLocaleDateString()}
                      </td>
                      <td className="relative whitespace-nowrap py-4 pl-3 pr-6 text-right text-sm font-medium">
                        <div className="flex items-center justify-end space-x-2">
                          <button
                            onClick={() => openEditModal(shop)}
                            title="Edit Shop & Credentials"
                            className="p-1.5 rounded-lg border text-gray-600 hover:bg-gray-50 border-gray-200 transition-all"
                          >
                            <Edit className="h-4 w-4" />
                          </button>
                          <button
                            onClick={() => handleTogglePause(shop.id, isExpired)}
                            title={isExpired ? 'Resume Subscription' : 'Pause Shop'}
                            className={`p-1.5 rounded-lg border transition-all ${isExpired ? 'text-green-600 hover:bg-green-50 border-green-200' : 'text-amber-600 hover:bg-amber-50 border-amber-200'}`}
                          >
                            {isExpired ? <Play className="h-4 w-4" /> : <Pause className="h-4 w-4" />}
                          </button>
                          <button
                            onClick={() => setDeleteConfirmId(shop.id)}
                            title="Delete Shop"
                            className="p-1.5 rounded-lg border text-red-600 hover:bg-red-50 border-red-200 transition-all"
                          >
                            <Trash2 className="h-4 w-4" />
                          </button>
                        </div>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </div>
      )}

      {/* Add Shop Modal */}
      {isAddOpen && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs px-4">
          <div className="w-full max-w-md bg-white rounded-2xl p-6 shadow-xl border border-gray-100">
            <div className="flex items-center justify-between border-b border-gray-100 pb-4 mb-4">
              <h3 className="text-lg font-bold text-gray-900">Add New Shop</h3>
              <button onClick={() => setIsAddOpen(false)} className="text-gray-400 hover:text-gray-600">
                <X className="h-5 w-5" />
              </button>
            </div>
            <form onSubmit={handleAddShop} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Shop Name</label>
                <input
                  type="text"
                  required
                  value={name}
                  onChange={(e) => setName(e.target.value)}
                  placeholder="e.g. Royal Tailors"
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Owner Name</label>
                <input
                  type="text"
                  required
                  value={ownerName}
                  onChange={(e) => setOwnerName(e.target.value)}
                  placeholder="e.g. Muhammad Ali"
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Phone / Contact</label>
                <input
                  type="text"
                  required
                  value={phone}
                  onChange={(e) => setPhone(e.target.value)}
                  placeholder="e.g. +923001234567"
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Password</label>
                <input
                  type="password"
                  required
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  placeholder="Minimum 6 characters"
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Initial Plan Length</label>
                <select
                  value={planYears}
                  onChange={(e) => setPlanYears(e.target.value)}
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                >
                  <option value="1">1 Year Plan</option>
                  <option value="2">2 Years Plan</option>
                  <option value="3">3 Years Plan</option>
                </select>
              </div>
              <div className="flex justify-end space-x-2 pt-4 border-t border-gray-100 mt-6">
                <button
                  type="button"
                  onClick={() => setIsAddOpen(false)}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-50 border border-gray-200 rounded-lg hover:bg-gray-100 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isPending}
                  className="px-4 py-2 text-sm font-medium text-white bg-gray-900 rounded-lg hover:bg-black transition-colors flex items-center disabled:opacity-50"
                >
                  {isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                  Create Shop
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Edit Shop Modal */}
      {editingShop && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs px-4">
          <div className="w-full max-w-md bg-white rounded-2xl p-6 shadow-xl border border-gray-100">
            <div className="flex items-center justify-between border-b border-gray-100 pb-4 mb-4">
              <h3 className="text-lg font-bold text-gray-900">Edit Shop & Credentials</h3>
              <button onClick={() => setEditingShop(null)} className="text-gray-400 hover:text-gray-600">
                <X className="h-5 w-5" />
              </button>
            </div>
            <form onSubmit={handleEditShop} className="space-y-4">
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Shop Name</label>
                <input
                  type="text"
                  required
                  value={editName}
                  onChange={(e) => setEditName(e.target.value)}
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Owner Name</label>
                <input
                  type="text"
                  required
                  value={editOwnerName}
                  onChange={(e) => setEditOwnerName(e.target.value)}
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Phone / Contact</label>
                <input
                  type="text"
                  required
                  value={editPhone}
                  onChange={(e) => setEditPhone(e.target.value)}
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                />
              </div>
              <div>
                <label className="block text-xs font-semibold text-gray-500 uppercase tracking-wider">Password (Optional)</label>
                <input
                  type="password"
                  value={editPassword}
                  onChange={(e) => setEditPassword(e.target.value)}
                  placeholder="Leave blank to keep current password"
                  className="mt-1 block w-full rounded-lg border border-gray-300 px-3 py-2 text-sm focus:border-gray-900 focus:outline-none focus:ring-1 focus:ring-gray-900"
                />
                <p className="mt-1 text-xs text-gray-400">Enter a new password (min. 6 characters) only if you want to reset it.</p>
              </div>
              <div className="flex justify-end space-x-2 pt-4 border-t border-gray-100 mt-6">
                <button
                  type="button"
                  onClick={() => setEditingShop(null)}
                  className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-50 border border-gray-200 rounded-lg hover:bg-gray-100 transition-colors"
                >
                  Cancel
                </button>
                <button
                  type="submit"
                  disabled={isPending}
                  className="px-4 py-2 text-sm font-medium text-white bg-gray-900 rounded-lg hover:bg-black transition-colors flex items-center disabled:opacity-50"
                >
                  {isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                  Save Changes
                </button>
              </div>
            </form>
          </div>
        </div>
      )}

      {/* Delete Confirmation Modal */}
      {deleteConfirmId && (
        <div className="fixed inset-0 z-50 flex items-center justify-center bg-black/40 backdrop-blur-xs px-4">
          <div className="w-full max-w-sm bg-white rounded-2xl p-6 shadow-xl border border-gray-100">
            <div className="flex flex-col items-center text-center">
              <div className="h-12 w-12 bg-red-50 rounded-full flex items-center justify-center border border-red-100 mb-4">
                <AlertTriangle className="h-6 w-6 text-red-600" />
              </div>
              <h3 className="text-lg font-bold text-gray-900">Delete Shop</h3>
              <p className="mt-2 text-sm text-gray-500">
                Are you sure you want to delete this shop? This will delete all order data and cannot be undone.
              </p>
            </div>
            <div className="flex justify-end space-x-2 pt-4 border-t border-gray-100 mt-6">
              <button
                type="button"
                onClick={() => setDeleteConfirmId(null)}
                className="px-4 py-2 text-sm font-medium text-gray-700 bg-gray-50 border border-gray-200 rounded-lg hover:bg-gray-100 transition-colors"
              >
                Cancel
              </button>
              <button
                onClick={() => handleDelete(deleteConfirmId)}
                disabled={isPending}
                className="px-4 py-2 text-sm font-medium text-white bg-red-600 rounded-lg hover:bg-red-700 transition-colors flex items-center disabled:opacity-50 animate-pulse"
              >
                {isPending && <Loader2 className="mr-2 h-4 w-4 animate-spin" />}
                Confirm Delete
              </button>
            </div>
          </div>
        </div>
      )}
    </div>
  );
}
