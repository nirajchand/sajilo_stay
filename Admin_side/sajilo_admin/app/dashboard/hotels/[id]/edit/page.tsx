'use client';

import { useEffect, useState } from 'react';
import { useParams, useRouter } from 'next/navigation';
import Link from 'next/link';
import { apiFetch, hotelImageUrl } from '@/lib/api';
import { MapPicker } from '@/components/MapPicker';

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
}

interface RoomRow {
  roomType: string;
  pricePerNight: string;
  capacity: string;
  roomImage: string;
}

const inputStyle: React.CSSProperties = {
  background: 'var(--bg-input)',
  border: '1px solid var(--border)',
  color: 'var(--text-primary)',
};

function DarkInput(props: React.InputHTMLAttributes<HTMLInputElement>) {
  return (
    <input
      {...props}
      className="w-full px-3 py-2.5 rounded-lg text-sm outline-none transition-all"
      style={inputStyle}
      onFocus={(e) => { e.currentTarget.style.borderColor = 'var(--border-focus)'; props.onFocus?.(e); }}
      onBlur={(e) => { e.currentTarget.style.borderColor = 'var(--border)'; props.onBlur?.(e); }}
    />
  );
}

function DarkTextarea(props: React.TextareaHTMLAttributes<HTMLTextAreaElement>) {
  return (
    <textarea
      {...props}
      className="w-full px-3 py-2.5 rounded-lg text-sm outline-none transition-all resize-none"
      style={inputStyle}
      onFocus={(e) => (e.currentTarget.style.borderColor = 'var(--border-focus)')}
      onBlur={(e) => (e.currentTarget.style.borderColor = 'var(--border)')}
    />
  );
}

function Card({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div className="rounded-xl p-5 space-y-4"
      style={{ background: 'var(--bg-surface)', border: '1px solid var(--border)' }}>
      <h2 className="text-sm font-semibold" style={{ color: 'var(--text-primary)' }}>{title}</h2>
      {children}
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="block text-xs font-medium mb-1.5 uppercase tracking-wide"
        style={{ color: 'var(--text-muted)' }}>
        {label}
      </label>
      {children}
    </div>
  );
}

export default function EditHotelPage() {
  const params = useParams();
  const router = useRouter();
  const id = params.id as string;

  const [hotel, setHotel] = useState<Hotel | null>(null);
  const [loading, setLoading] = useState(true);
  const [notFound, setNotFound] = useState(false);

  const [hotelName, setHotelName] = useState('');
  const [description, setDescription] = useState('');
  const [location, setLocation] = useState({ lat: 0, lng: 0, address: '' });
  const [rooms, setRooms] = useState<RoomRow[]>([]);

  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');
  const [success, setSuccess] = useState('');

  useEffect(() => {
    apiFetch(`/hotels/${id}`)
      .then((r) => r.json())
      .then((data) => {
        if (!data.success || !data.data) { setNotFound(true); return; }
        const h: Hotel = data.data;
        setHotel(h);
        setHotelName(h.hotelName);
        setDescription(h.description);
        setLocation({
          lat: h.location?.coordinates?.[0] ?? 0,
          lng: h.location?.coordinates?.[1] ?? 0,
          address: h.location?.address ?? '',
        });
        setRooms((h.rooms ?? []).map((r) => ({
          roomType: r.roomType,
          pricePerNight: String(r.pricePerNight),
          capacity: String(r.capacity),
          roomImage: r.roomImage ?? '',
        })));
      })
      .catch(() => setNotFound(true))
      .finally(() => setLoading(false));
  }, [id]);

  function updateRoom(index: number, field: keyof RoomRow, value: string) {
    setRooms((prev) => prev.map((r, i) => (i === index ? { ...r, [field]: value } : r)));
  }

  function addRoom() {
    if (rooms.length < 5) setRooms((prev) => [...prev, { roomType: '', pricePerNight: '', capacity: '', roomImage: '' }]);
  }

  function removeRoom(index: number) {
    if (rooms.length > 1) setRooms((prev) => prev.filter((_, i) => i !== index));
  }

  async function handleSubmit(e: { preventDefault(): void }) {
    e.preventDefault();
    setError('');
    setSuccess('');

    if (!location.address.trim()) { setError('Please enter a location address'); return; }
    if (rooms.some((r) => !r.roomType || !r.pricePerNight || !r.capacity)) {
      setError('Fill in all room fields');
      return;
    }

    setSubmitting(true);
    try {
      const payload = {
        hotelName,
        description,
        location: {
          address: location.address,
          coordinates: [location.lat, location.lng],
        },
        rooms: rooms.map((r) => ({
          roomType: r.roomType,
          pricePerNight: parseFloat(r.pricePerNight),
          capacity: parseInt(r.capacity, 10),
          ...(r.roomImage ? { roomImage: r.roomImage } : {}),
        })),
      };

      const res = await apiFetch(`/hotels/${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(payload),
      });
      const data = await res.json();
      if (!data.success) {
        setError(typeof data.message === 'string' ? data.message : JSON.stringify(data.message));
        return;
      }
      setSuccess('Hotel updated successfully!');
      setTimeout(() => router.push('/dashboard/hotels'), 1200);
    } catch {
      setError('Failed to update hotel. Check your connection.');
    } finally {
      setSubmitting(false);
    }
  }

  if (loading) {
    return (
      <div className="p-8 flex items-center justify-center min-h-[400px]">
        <p className="text-sm" style={{ color: 'var(--text-muted)' }}>Loading hotel...</p>
      </div>
    );
  }

  if (notFound) {
    return (
      <div className="p-8 flex flex-col items-center justify-center min-h-[400px] gap-3">
        <p style={{ color: 'var(--text-muted)' }}>Hotel not found.</p>
        <Link href="/dashboard/hotels" className="text-sm" style={{ color: 'var(--accent)' }}>
          Back to Hotels
        </Link>
      </div>
    );
  }

  return (
    <div className="p-8 max-w-2xl">
      {/* Header */}
      <div className="flex items-center gap-3 mb-7">
        <Link
          href="/dashboard/hotels"
          className="w-8 h-8 rounded-lg flex items-center justify-center"
          style={{ background: 'var(--bg-surface)', border: '1px solid var(--border)', color: 'var(--text-secondary)' }}
        >
          <svg className="w-4 h-4" fill="none" stroke="currentColor" viewBox="0 0 24 24">
            <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 19l-7-7 7-7" />
          </svg>
        </Link>
        <div>
          <h1 className="text-xl font-semibold" style={{ color: 'var(--text-primary)' }}>Edit Hotel</h1>
          <p className="text-sm mt-0.5" style={{ color: 'var(--text-muted)' }}>{hotel?.hotelName}</p>
        </div>
      </div>

      {/* Gallery (read-only) */}
      {hotel?.gallery && hotel.gallery.length > 0 && (
        <div className="mb-4 rounded-xl p-5 space-y-3"
          style={{ background: 'var(--bg-surface)', border: '1px solid var(--border)' }}>
          <p className="text-xs font-semibold uppercase tracking-wide" style={{ color: 'var(--text-muted)' }}>
            Current Gallery
          </p>
          <div className="flex flex-wrap gap-2">
            {hotel.gallery.map((src, i) => (
              // eslint-disable-next-line @next/next/no-img-element
              <img key={i} src={hotelImageUrl(src)} alt="" className="w-20 h-20 object-cover rounded-lg" />
            ))}
          </div>
          <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
            Gallery images cannot be changed after creation.
          </p>
        </div>
      )}

      {error && (
        <div className="mb-4 text-sm rounded-xl px-4 py-3"
          style={{ background: 'var(--danger-subtle)', border: '1px solid rgba(240,82,82,0.2)', color: 'var(--danger)' }}>
          {error}
        </div>
      )}
      {success && (
        <div className="mb-4 text-sm rounded-xl px-4 py-3"
          style={{ background: 'var(--success-subtle)', border: '1px solid rgba(34,197,94,0.2)', color: 'var(--success)' }}>
          {success}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-4">
        {/* Basic Info */}
        <Card title="Basic Information">
          <Field label="Hotel Name">
            <DarkInput type="text" required minLength={3} value={hotelName}
              onChange={(e) => setHotelName(e.target.value)} />
          </Field>
          <Field label="Description">
            <DarkTextarea required minLength={10} rows={3} value={description}
              onChange={(e) => setDescription(e.target.value)} />
          </Field>
        </Card>

        {/* Location */}
        <Card title="Location">
          <Field label="Address / Location Name">
            <DarkInput
              type="text"
              value={location.address}
              onChange={(e) => setLocation((prev) => ({ ...prev, address: e.target.value }))}
              placeholder="e.g. Thamel, Kathmandu, Nepal"
            />
          </Field>
          <p className="text-xs" style={{ color: 'var(--text-muted)' }}>
            Or pick on the map — the address will auto-fill.
          </p>
          {location.lat !== 0 && location.lng !== 0 ? (
            <MapPicker
              initialLat={location.lat}
              initialLng={location.lng}
              onLocationChange={(lat, lng, address) => setLocation({ lat, lng, address })}
            />
          ) : (
            <MapPicker onLocationChange={(lat, lng, address) => setLocation({ lat, lng, address })} />
          )}
        </Card>

        {/* Rooms */}
        <Card title="Room Types">
          <div className="flex items-center justify-between -mt-1">
            <p className="text-xs" style={{ color: 'var(--text-muted)' }}>Update room types and pricing</p>
            {rooms.length < 5 && (
              <button type="button" onClick={addRoom}
                className="inline-flex items-center gap-1 text-xs font-medium"
                style={{ color: 'var(--accent)' }}>
                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
                Add Room
              </button>
            )}
          </div>

          <div className="space-y-3">
            {rooms.map((room, idx) => (
              <div key={idx} className="rounded-xl p-4 space-y-3"
                style={{ background: 'var(--bg-elevated)', border: '1px solid var(--border)' }}>
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold uppercase tracking-wide" style={{ color: 'var(--text-muted)' }}>
                    Room {idx + 1}
                  </span>
                  {rooms.length > 1 && (
                    <button type="button" onClick={() => removeRoom(idx)}
                      className="text-xs" style={{ color: 'var(--danger)' }}>
                      Remove
                    </button>
                  )}
                </div>

                <Field label="Room Type Name">
                  <DarkInput type="text" required value={room.roomType}
                    onChange={(e) => updateRoom(idx, 'roomType', e.target.value)}
                    placeholder="e.g. Deluxe Room, Suite" />
                </Field>

                <div className="grid grid-cols-2 gap-3">
                  <Field label="Price / Night (Rs.)">
                    <DarkInput type="number" required min={1} step="0.01" value={room.pricePerNight}
                      onChange={(e) => updateRoom(idx, 'pricePerNight', e.target.value)} />
                  </Field>
                  <Field label="Capacity (guests)">
                    <DarkInput type="number" required min={1} step={1} value={room.capacity}
                      onChange={(e) => updateRoom(idx, 'capacity', e.target.value)} />
                  </Field>
                </div>

                {room.roomImage && (
                  <div>
                    <p className="text-xs mb-1.5 uppercase tracking-wide font-medium"
                      style={{ color: 'var(--text-muted)' }}>Current Room Image</p>
                    {/* eslint-disable-next-line @next/next/no-img-element */}
                    <img src={hotelImageUrl(room.roomImage)} alt="" className="w-16 h-16 object-cover rounded-lg" />
                  </div>
                )}
              </div>
            ))}
          </div>
        </Card>

        {/* Actions */}
        <div className="flex items-center gap-3 pt-1">
          <button
            type="submit" disabled={submitting}
            className="px-6 py-2.5 rounded-lg text-sm font-medium text-white transition-all disabled:opacity-50"
            style={{ background: submitting ? 'var(--text-muted)' : 'var(--accent)' }}
            onMouseEnter={(e) => { if (!submitting) e.currentTarget.style.background = 'var(--accent-hover)'; }}
            onMouseLeave={(e) => { if (!submitting) e.currentTarget.style.background = 'var(--accent)'; }}
          >
            {submitting ? 'Saving...' : 'Save Changes'}
          </button>
          <Link href="/dashboard/hotels"
            className="px-6 py-2.5 rounded-lg text-sm font-medium transition-all"
            style={{ background: 'var(--bg-elevated)', border: '1px solid var(--border)', color: 'var(--text-secondary)' }}>
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
