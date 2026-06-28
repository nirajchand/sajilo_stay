'use client';

import { useEffect, useState } from 'react';
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

export default function DashboardPage() {
  const [hotels, setHotels] = useState<Hotel[]>([]);
  const [loading, setLoading] = useState(true);

  useEffect(() => {
    apiFetch('/hotels')
      .then((r) => r.json())
      .then((data) => { if (data.success) setHotels(data.data ?? []); })
      .catch(() => {})
      .finally(() => setLoading(false));
  }, []);

  const totalRooms = hotels.reduce((s, h) => s + (h.rooms?.length ?? 0), 0);
  const minPrices = hotels.map((h) => Math.min(...(h.rooms ?? []).map((r) => r.pricePerNight).filter(Boolean)));
  const avgPrice = minPrices.length > 0
    ? Math.round(minPrices.filter(isFinite).reduce((a, b) => a + b, 0) / minPrices.filter(isFinite).length)
    : 0;

  const stats = [
    {
      label: 'Total Hotels',
      value: hotels.length,
      icon: (
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.75} d="M19 21V5a2 2 0 00-2-2H7a2 2 0 00-2 2v16m14 0h2m-2 0h-5m-9 0H3m2 0h5M9 7h1m-1 4h1m4-4h1m-1 4h1m-5 10v-5a1 1 0 011-1h2a1 1 0 011 1v5m-4 0h4" />
        </svg>
      ),
      accent: '#4f6ef7',
      accentSubtle: 'rgba(79,110,247,0.12)',
    },
    {
      label: 'Room Types',
      value: totalRooms,
      icon: (
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.75} d="M4 6h16M4 10h16M4 14h16M4 18h16" />
        </svg>
      ),
      accent: '#a78bfa',
      accentSubtle: 'rgba(167,139,250,0.12)',
    },
    {
      label: 'Avg Starting Price',
      value: avgPrice > 0 ? `Rs. ${avgPrice.toLocaleString()}` : '—',
      icon: (
        <svg className="w-5 h-5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.75} d="M12 8c-1.657 0-3 .895-3 2s1.343 2 3 2 3 .895 3 2-1.343 2-3 2m0-8c1.11 0 2.08.402 2.599 1M12 8V7m0 1v8m0 0v1m0-1c-1.11 0-2.08-.402-2.599-1M21 12a9 9 0 11-18 0 9 9 0 0118 0z" />
        </svg>
      ),
      accent: '#34d399',
      accentSubtle: 'rgba(52,211,153,0.12)',
    },
  ];

  return (
    <div className="p-8">
      {/* Header */}
      <div className="flex items-center justify-between mb-8">
        <div>
          <h1 className="text-xl font-semibold" style={{ color: 'var(--text-primary)' }}>
            Overview
          </h1>
          <p className="text-sm mt-0.5" style={{ color: 'var(--text-muted)' }}>
            Welcome back to Sajilo Stay admin
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

      {/* Stat cards */}
      <div className="grid grid-cols-3 gap-4 mb-8">
        {stats.map((s) => (
          <div
            key={s.label}
            className="rounded-xl p-5"
            style={{
              background: 'var(--bg-surface)',
              border: '1px solid var(--border)',
            }}
          >
            <div
              className="w-9 h-9 rounded-lg flex items-center justify-center mb-4"
              style={{ background: s.accentSubtle, color: s.accent }}
            >
              {s.icon}
            </div>
            <div className="text-2xl font-semibold" style={{ color: 'var(--text-primary)' }}>
              {loading ? <span style={{ color: 'var(--text-muted)' }}>—</span> : s.value}
            </div>
            <div className="text-xs mt-1" style={{ color: 'var(--text-muted)' }}>
              {s.label}
            </div>
          </div>
        ))}
      </div>

      {/* Recent hotels */}
      <div
        className="rounded-xl overflow-hidden"
        style={{ background: 'var(--bg-surface)', border: '1px solid var(--border)' }}
      >
        <div
          className="flex items-center justify-between px-5 py-3.5"
          style={{ borderBottom: '1px solid var(--border)' }}
        >
          <p className="text-sm font-medium" style={{ color: 'var(--text-primary)' }}>
            Recent Hotels
          </p>
          <Link
            href="/dashboard/hotels"
            className="text-xs font-medium transition-colors"
            style={{ color: 'var(--accent)' }}
          >
            View all →
          </Link>
        </div>

        {loading ? (
          <div className="py-12 text-center text-sm" style={{ color: 'var(--text-muted)' }}>
            Loading...
          </div>
        ) : hotels.length === 0 ? (
          <div className="py-12 text-center">
            <p className="text-sm mb-2" style={{ color: 'var(--text-muted)' }}>No hotels yet</p>
            <Link
              href="/dashboard/hotels/create"
              className="text-sm"
              style={{ color: 'var(--accent)' }}
            >
              Create your first hotel
            </Link>
          </div>
        ) : (
          <div>
            {hotels.slice(0, 5).map((hotel, idx) => {
              const prices = (hotel.rooms ?? []).map((r) => r.pricePerNight).filter(Boolean);
              const minPrice = prices.length > 0 ? Math.min(...prices) : null;
              const isLast = idx === Math.min(hotels.length - 1, 4);
              return (
                <div
                  key={hotel._id}
                  className="flex items-center gap-4 px-5 py-3 transition-colors"
                  style={{
                    borderBottom: isLast ? 'none' : '1px solid var(--border)',
                  }}
                >
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
                  <div className="flex-1 min-w-0">
                    <p className="text-sm font-medium truncate" style={{ color: 'var(--text-primary)' }}>
                      {hotel.hotelName}
                    </p>
                    <p className="text-xs truncate mt-0.5" style={{ color: 'var(--text-muted)' }}>
                      {hotel.location?.address}
                    </p>
                  </div>
                  <div className="text-sm flex-shrink-0" style={{ color: 'var(--text-secondary)' }}>
                    {minPrice != null ? `Rs. ${minPrice.toLocaleString()}/night` : '—'}
                  </div>
                  <Link
                    href={`/dashboard/hotels/${hotel._id}/edit`}
                    className="text-xs flex-shrink-0 px-2.5 py-1 rounded-md transition-colors"
                    style={{
                      color: 'var(--accent)',
                      background: 'var(--accent-subtle)',
                    }}
                  >
                    Edit
                  </Link>
                </div>
              );
            })}
          </div>
        )}
      </div>
    </div>
  );
}
