'use client';

import { useEffect, useState, useCallback } from 'react';
import Link from 'next/link';
import { apiFetch, hotelImageUrl } from '@/lib/api';

interface Room {
  roomType: string;
  pricePerNight: number;
  capacity: number;
  roomImage?: string;
}

interface Hotel {
  _id: string;
  hotelName: string;
  description: string;
  location: { address: string; coordinates: number[] };
  gallery: string[];
  rooms: Room[];
  createdAt: string;
}

export default function HotelsPage() {
  const [hotels, setHotels] = useState<Hotel[]>([]);
  const [loading, setLoading] = useState(true);
  const [deletingId, setDeletingId] = useState<string | null>(null);
  const [search, setSearch] = useState('');
  const [error, setError] = useState('');

  const fetchHotels = useCallback(async () => {
    setLoading(true);
    try {
      const res = await apiFetch('/hotels');
      const data = await res.json();
      if (data.success) setHotels(data.data ?? []);
    } catch {
      setError('Failed to load hotels');
    } finally {
      setLoading(false);
    }
  }, []);

  useEffect(() => { fetchHotels(); }, [fetchHotels]);

  async function handleDelete(id: string, name: string) {
    if (!confirm(`Delete "${name}"? This cannot be undone.`)) return;
    setDeletingId(id);
    try {
      const res = await apiFetch(`/hotels/${id}`, { method: 'DELETE' });
      const data = await res.json();
      if (data.success) {
        setHotels((prev) => prev.filter((h) => h._id !== id));
      } else {
        alert(data.message || 'Failed to delete hotel');
      }
    } catch {
      alert('Failed to delete hotel');
    } finally {
      setDeletingId(null);
    }
  }

  const filtered = hotels.filter(
    (h) =>
      h.hotelName.toLowerCase().includes(search.toLowerCase()) ||
      h.location?.address.toLowerCase().includes(search.toLowerCase())
  );

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-6">
        <div>
          <h1 className="text-xl font-semibold" style={{ color: 'var(--text-primary)' }}>
            Hotels
          </h1>
          <p className="text-sm mt-0.5" style={{ color: 'var(--text-muted)' }}>
            {hotels.length} hotel{hotels.length !== 1 ? 's' : ''} total
          </p>
        </div>
        <Link
          href="/dashboard/hotels/create"
          className="inline-flex items-center gap-2 px-4 py-2 rounded-lg text-sm font-medium text-white transition-all"
          style={{ background: 'var(--accent)' }}
          onMouseEnter={(e) => (e.currentTarget.style.background = 'var(--accent-hover)')}
          onMouseLeave={(e) => (e.currentTarget.style.background = 'var(--accent)')}
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
          </svg>
          Add Hotel
        </Link>
      </div>

      {/* Search */}
      <div className="mb-5">
        <div className="relative max-w-xs">
          <svg
            className="w-4 h-4 absolute left-3 top-1/2 -translate-y-1/2"
            style={{ color: 'var(--text-muted)' }}
            fill="none" stroke="currentColor" viewBox="0 0 24 24"
          >
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
          </svg>
          <input
            type="text"
            placeholder="Search hotels or location..."
            value={search}
            onChange={(e) => setSearch(e.target.value)}
            className="w-full pl-9 pr-3 py-2 rounded-lg text-sm outline-none"
            style={{
              background: 'var(--bg-surface)',
              border: '1px solid var(--border)',
              color: 'var(--text-primary)',
            }}
            onFocus={(e) => (e.currentTarget.style.borderColor = 'var(--border-focus)')}
            onBlur={(e) => (e.currentTarget.style.borderColor = 'var(--border)')}
          />
        </div>
      </div>

      {error && (
        <div
          className="mb-4 text-sm rounded-lg px-4 py-3"
          style={{ background: 'var(--danger-subtle)', border: '1px solid rgba(240,82,82,0.2)', color: 'var(--danger)' }}
        >
          {error}
        </div>
      )}

      {/* Table */}
      <div
        className="rounded-xl overflow-hidden"
        style={{ background: 'var(--bg-surface)', border: '1px solid var(--border)' }}
      >
        <table className="w-full text-sm">
          <thead>
            <tr style={{ borderBottom: '1px solid var(--border)' }}>
              {['Hotel', 'Location', 'Rooms', 'Starting Price', ''].map((h) => (
                <th
                  key={h}
                  className={`px-5 py-3 text-left text-xs font-semibold uppercase tracking-wide ${h === '' ? 'text-right' : ''}`}
                  style={{ color: 'var(--text-muted)' }}
                >
                  {h}
                </th>
              ))}
            </tr>
          </thead>
          <tbody>
            {loading ? (
              <tr>
                <td colSpan={5} className="px-5 py-12 text-center text-sm" style={{ color: 'var(--text-muted)' }}>
                  Loading hotels...
                </td>
              </tr>
            ) : filtered.length === 0 ? (
              <tr>
                <td colSpan={5} className="px-5 py-12 text-center">
                  <p className="text-sm mb-2" style={{ color: 'var(--text-muted)' }}>
                    {search ? 'No hotels match your search' : 'No hotels yet'}
                  </p>
                  {!search && (
                    <Link href="/dashboard/hotels/create" className="text-sm" style={{ color: 'var(--accent)' }}>
                      Create your first hotel
                    </Link>
                  )}
                </td>
              </tr>
            ) : (
              filtered.map((hotel, idx) => {
                const prices = (hotel.rooms ?? []).map((r) => r.pricePerNight).filter(Boolean);
                const minPrice = prices.length > 0 ? Math.min(...prices) : null;
                const isLast = idx === filtered.length - 1;
                return (
                  <tr
                    key={hotel._id}
                    style={{ borderBottom: isLast ? 'none' : '1px solid var(--border)' }}
                  >
                    {/* Hotel name + image */}
                    <td className="px-5 py-3.5">
                      <div className="flex items-center gap-3">
                        {hotel.gallery?.[0] ? (
                          // eslint-disable-next-line @next/next/no-img-element
                          <img
                            src={hotelImageUrl(hotel.gallery[0])}
                            alt=""
                            className="w-9 h-9 rounded-lg object-cover flex-shrink-0"
                          />
                        ) : (
                          <div
                            className="w-9 h-9 rounded-lg flex-shrink-0"
                            style={{ background: 'var(--bg-elevated)' }}
                          />
                        )}
                        <div>
                          <p className="font-medium" style={{ color: 'var(--text-primary)' }}>
                            {hotel.hotelName}
                          </p>
                          <p
                            className="text-xs mt-0.5 max-w-[180px] truncate"
                            style={{ color: 'var(--text-muted)' }}
                          >
                            {hotel.description}
                          </p>
                        </div>
                      </div>
                    </td>
                    {/* Location */}
                    <td className="px-5 py-3.5 max-w-[160px]">
                      <p className="truncate" style={{ color: 'var(--text-secondary)' }}>
                        {hotel.location?.address}
                      </p>
                    </td>
                    {/* Rooms */}
                    <td className="px-5 py-3.5">
                      <span
                        className="inline-flex items-center px-2 py-0.5 rounded-md text-xs font-medium"
                        style={{
                          background: 'rgba(167,139,250,0.1)',
                          color: '#a78bfa',
                        }}
                      >
                        {hotel.rooms?.length ?? 0} type{(hotel.rooms?.length ?? 0) !== 1 ? 's' : ''}
                      </span>
                    </td>
                    {/* Price */}
                    <td className="px-5 py-3.5">
                      <span className="font-medium" style={{ color: 'var(--text-primary)' }}>
                        {minPrice != null ? `Rs. ${minPrice.toLocaleString()}` : '—'}
                      </span>
                      {minPrice != null && (
                        <span className="text-xs ml-1" style={{ color: 'var(--text-muted)' }}>/night</span>
                      )}
                    </td>
                    {/* Actions */}
                    <td className="px-5 py-3.5">
                      <div className="flex items-center justify-end gap-2">
                        <Link
                          href={`/dashboard/hotels/${hotel._id}/edit`}
                          className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all"
                          style={{
                            background: 'var(--bg-elevated)',
                            color: 'var(--text-secondary)',
                            border: '1px solid var(--border)',
                          }}
                        >
                          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M11 5H6a2 2 0 00-2 2v11a2 2 0 002 2h11a2 2 0 002-2v-5m-1.414-9.414a2 2 0 112.828 2.828L11.828 15H9v-2.828l8.586-8.586z" />
                          </svg>
                          Edit
                        </Link>
                        <button
                          onClick={() => handleDelete(hotel._id, hotel.hotelName)}
                          disabled={deletingId === hotel._id}
                          className="inline-flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-medium transition-all disabled:opacity-40"
                          style={{
                            background: 'var(--danger-subtle)',
                            color: 'var(--danger)',
                            border: '1px solid rgba(240,82,82,0.2)',
                          }}
                        >
                          <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M19 7l-.867 12.142A2 2 0 0116.138 21H7.862a2 2 0 01-1.995-1.858L5 7m5 4v6m4-6v6m1-10V4a1 1 0 00-1-1h-4a1 1 0 00-1 1v3M4 7h16" />
                          </svg>
                          {deletingId === hotel._id ? 'Deleting...' : 'Delete'}
                        </button>
                      </div>
                    </td>
                  </tr>
                );
              })
            )}
          </tbody>
        </table>
      </div>
    </div>
  );
}
