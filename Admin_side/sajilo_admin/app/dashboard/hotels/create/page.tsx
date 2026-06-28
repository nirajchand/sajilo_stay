'use client';

import { useState, useRef } from 'react';
import { useRouter } from 'next/navigation';
import Link from 'next/link';
import { apiFetch } from '@/lib/api';
import { MapPicker } from '@/components/MapPicker';

interface RoomRow {
  roomType: string;
  pricePerNight: string;
  capacity: string;
  imageFile: File | null;
  imagePreview: string;
}

function emptyRoom(): RoomRow {
  return { roomType: '', pricePerNight: '', capacity: '', imageFile: null, imagePreview: '' };
}

function Card({ title, children }: { title: string; children: React.ReactNode }) {
  return (
    <div
      className="rounded-xl p-5 space-y-4"
      style={{ background: 'var(--bg-surface)', border: '1px solid var(--border)' }}
    >
      <h2 className="text-sm font-semibold" style={{ color: 'var(--text-primary)' }}>
        {title}
      </h2>
      {children}
    </div>
  );
}

function Field({ label, children }: { label: string; children: React.ReactNode }) {
  return (
    <div>
      <label className="block text-xs font-medium mb-1.5 uppercase tracking-wide" style={{ color: 'var(--text-muted)' }}>
        {label}
      </label>
      {children}
    </div>
  );
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
      className={`w-full px-3 py-2.5 rounded-lg text-sm outline-none transition-all ${props.className ?? ''}`}
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

export default function CreateHotelPage() {
  const router = useRouter();

  const [hotelName, setHotelName] = useState('');
  const [description, setDescription] = useState('');

  const [location, setLocation] = useState({ lat: 0, lng: 0, address: '' });

  const [galleryFiles, setGalleryFiles] = useState<File[]>([]);
  const [galleryPreviews, setGalleryPreviews] = useState<string[]>([]);
  const galleryInputRef = useRef<HTMLInputElement>(null);

  const [rooms, setRooms] = useState<RoomRow[]>([emptyRoom()]);
  const [submitting, setSubmitting] = useState(false);
  const [error, setError] = useState('');

  function handleGalleryChange(e: React.ChangeEvent<HTMLInputElement>) {
    const files = Array.from(e.target.files ?? []);
    if (files.length + galleryFiles.length > 5) {
      setError('Maximum 5 gallery images allowed');
      return;
    }
    setGalleryFiles((prev) => [...prev, ...files]);
    setGalleryPreviews((prev) => [...prev, ...files.map((f) => URL.createObjectURL(f))]);
    if (galleryInputRef.current) galleryInputRef.current.value = '';
  }

  function removeGalleryImage(i: number) {
    URL.revokeObjectURL(galleryPreviews[i]);
    setGalleryFiles((prev) => prev.filter((_, j) => j !== i));
    setGalleryPreviews((prev) => prev.filter((_, j) => j !== i));
  }

  function updateRoom(index: number, field: keyof RoomRow, value: string | File | null) {
    setRooms((prev) =>
      prev.map((r, i) => {
        if (i !== index) return r;
        if (field === 'imageFile' && value instanceof File) {
          if (r.imagePreview) URL.revokeObjectURL(r.imagePreview);
          return { ...r, imageFile: value, imagePreview: URL.createObjectURL(value) };
        }
        return { ...r, [field]: value };
      })
    );
  }

  function addRoom() {
    if (rooms.length < 5) setRooms((prev) => [...prev, emptyRoom()]);
  }

  function removeRoom(index: number) {
    if (rooms.length === 1) return;
    const room = rooms[index];
    if (room.imagePreview) URL.revokeObjectURL(room.imagePreview);
    setRooms((prev) => prev.filter((_, i) => i !== index));
  }

  async function handleSubmit(e: { preventDefault(): void }) {
    e.preventDefault();
    setError('');

    if (!location.address.trim()) {
      setError('Please enter a location address');
      return;
    }
    if (galleryFiles.length < 1) {
      setError('Upload at least 1 gallery image');
      return;
    }
    if (rooms.some((r) => !r.imageFile)) {
      setError('Upload an image for every room type');
      return;
    }
    if (rooms.some((r) => !r.roomType || !r.pricePerNight || !r.capacity)) {
      setError('Fill in all room fields');
      return;
    }

    setSubmitting(true);
    try {
      const formData = new FormData();
      formData.append('hotelName', hotelName);
      formData.append('description', description);
      formData.append(
        'location',
        JSON.stringify({ address: location.address, coordinates: [location.lat, location.lng] })
      );
      formData.append(
        'rooms',
        JSON.stringify(
          rooms.map((r) => ({
            roomType: r.roomType,
            pricePerNight: parseFloat(r.pricePerNight),
            capacity: parseInt(r.capacity, 10),
          }))
        )
      );
      galleryFiles.forEach((f) => formData.append('gallery', f));
      rooms.forEach((r) => { if (r.imageFile) formData.append('roomImages', r.imageFile); });

      const res = await apiFetch('/hotels/create-hotel', { method: 'POST', body: formData });
      const data = await res.json();
      if (!data.success) {
        setError(typeof data.message === 'string' ? data.message : JSON.stringify(data.message));
        return;
      }
      router.push('/dashboard/hotels');
    } catch {
      setError('Failed to create hotel. Check your connection.');
    } finally {
      setSubmitting(false);
    }
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
          <h1 className="text-xl font-semibold" style={{ color: 'var(--text-primary)' }}>Add Hotel</h1>
          <p className="text-sm mt-0.5" style={{ color: 'var(--text-muted)' }}>Fill in the details to list a new property</p>
        </div>
      </div>

      {error && (
        <div className="mb-5 text-sm rounded-xl px-4 py-3"
          style={{ background: 'var(--danger-subtle)', border: '1px solid rgba(240,82,82,0.2)', color: 'var(--danger)' }}>
          {error}
        </div>
      )}

      <form onSubmit={handleSubmit} className="space-y-4">
        {/* Basic Info */}
        <Card title="Basic Information">
          <Field label="Hotel Name">
            <DarkInput
              type="text" required minLength={3} value={hotelName}
              onChange={(e) => setHotelName(e.target.value)}
              placeholder="e.g. Himalayan Grand Hotel"
            />
          </Field>
          <Field label="Description">
            <DarkTextarea
              required minLength={10} rows={3} value={description}
              onChange={(e) => setDescription(e.target.value)}
              placeholder="Describe the hotel experience..."
            />
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
            Or pick directly on the map — the address will auto-fill.
          </p>
          <MapPicker onLocationChange={(lat, lng, address) => setLocation({ lat, lng, address })} />
        </Card>

        {/* Gallery */}
        <Card title="Gallery Images">
          <div className="flex items-center justify-between -mt-1">
            <p className="text-xs" style={{ color: 'var(--text-muted)' }}>Upload 1–5 images (max 5 MB each)</p>
            <span className="text-xs font-medium"
              style={{ color: galleryFiles.length >= 5 ? 'var(--danger)' : 'var(--text-muted)' }}>
              {galleryFiles.length}/5
            </span>
          </div>

          {galleryPreviews.length > 0 && (
            <div className="flex flex-wrap gap-2">
              {galleryPreviews.map((src, i) => (
                <div key={i} className="relative group">
                  {/* eslint-disable-next-line @next/next/no-img-element */}
                  <img src={src} alt="" className="w-20 h-20 object-cover rounded-lg" />
                  <button
                    type="button"
                    onClick={() => removeGalleryImage(i)}
                    className="absolute -top-1.5 -right-1.5 w-5 h-5 rounded-full text-xs font-bold flex items-center justify-center opacity-0 group-hover:opacity-100 transition-opacity text-white"
                    style={{ background: 'var(--danger)' }}
                  >
                    ×
                  </button>
                </div>
              ))}
            </div>
          )}

          {galleryFiles.length < 5 && (
            <label
              className="flex flex-col items-center justify-center w-full h-24 rounded-xl cursor-pointer transition-all"
              style={{ border: '2px dashed var(--border)' }}
              onMouseEnter={(e) => (e.currentTarget.style.borderColor = 'var(--accent)')}
              onMouseLeave={(e) => (e.currentTarget.style.borderColor = 'var(--border)')}
            >
              <svg className="w-5 h-5 mb-1.5" style={{ color: 'var(--text-muted)' }} fill="none" stroke="currentColor" viewBox="0 0 24 24">
                <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
                  d="M4 16l4.586-4.586a2 2 0 012.828 0L16 16m-2-2l1.586-1.586a2 2 0 012.828 0L20 14m-6-6h.01M6 20h12a2 2 0 002-2V6a2 2 0 00-2-2H6a2 2 0 00-2 2v12a2 2 0 002 2z" />
              </svg>
              <span className="text-xs" style={{ color: 'var(--text-muted)' }}>Click to upload photos</span>
              <input ref={galleryInputRef} type="file" accept="image/*" multiple className="hidden"
                onChange={handleGalleryChange} />
            </label>
          )}
        </Card>

        {/* Rooms */}
        <Card title="Room Types">
          <div className="flex items-center justify-between -mt-1">
            <p className="text-xs" style={{ color: 'var(--text-muted)' }}>Add at least one room type with an image</p>
            {rooms.length < 5 && (
              <button
                type="button" onClick={addRoom}
                className="inline-flex items-center gap-1 text-xs font-medium"
                style={{ color: 'var(--accent)' }}
              >
                <svg className="w-3.5 h-3.5" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M12 4v16m8-8H4" />
                </svg>
                Add Room
              </button>
            )}
          </div>

          <div className="space-y-3">
            {rooms.map((room, idx) => (
              <div
                key={idx}
                className="rounded-xl p-4 space-y-3"
                style={{ background: 'var(--bg-elevated)', border: '1px solid var(--border)' }}
              >
                <div className="flex items-center justify-between">
                  <span className="text-xs font-semibold uppercase tracking-wide" style={{ color: 'var(--text-muted)' }}>
                    Room {idx + 1}
                  </span>
                  {rooms.length > 1 && (
                    <button type="button" onClick={() => removeRoom(idx)} className="text-xs"
                      style={{ color: 'var(--danger)' }}>
                      Remove
                    </button>
                  )}
                </div>

                <Field label="Room Type Name">
                  <DarkInput
                    type="text" required value={room.roomType}
                    onChange={(e) => updateRoom(idx, 'roomType', e.target.value)}
                    placeholder="e.g. Deluxe Room, Suite, Standard"
                  />
                </Field>

                <div className="grid grid-cols-2 gap-3">
                  <Field label="Price / Night (Rs.)">
                    <DarkInput type="number" required min={1} step="0.01" value={room.pricePerNight}
                      onChange={(e) => updateRoom(idx, 'pricePerNight', e.target.value)} placeholder="3000" />
                  </Field>
                  <Field label="Capacity (guests)">
                    <DarkInput type="number" required min={1} step={1} value={room.capacity}
                      onChange={(e) => updateRoom(idx, 'capacity', e.target.value)} placeholder="2" />
                  </Field>
                </div>

                <Field label="Room Image">
                  {room.imagePreview ? (
                    <div className="flex items-center gap-3">
                      {/* eslint-disable-next-line @next/next/no-img-element */}
                      <img src={room.imagePreview} alt="" className="w-14 h-14 object-cover rounded-lg" />
                      <label className="text-xs cursor-pointer" style={{ color: 'var(--accent)' }}>
                        Change image
                        <input type="file" accept="image/*" className="hidden"
                          onChange={(e) => { const f = e.target.files?.[0]; if (f) updateRoom(idx, 'imageFile', f); }} />
                      </label>
                    </div>
                  ) : (
                    <label
                      className="flex items-center justify-center w-full h-14 rounded-lg cursor-pointer transition-all"
                      style={{ border: '2px dashed var(--border)' }}
                      onMouseEnter={(e) => (e.currentTarget.style.borderColor = 'var(--accent)')}
                      onMouseLeave={(e) => (e.currentTarget.style.borderColor = 'var(--border)')}
                    >
                      <span className="text-xs" style={{ color: 'var(--text-muted)' }}>Upload room photo</span>
                      <input type="file" accept="image/*" className="hidden"
                        onChange={(e) => { const f = e.target.files?.[0]; if (f) updateRoom(idx, 'imageFile', f); }} />
                    </label>
                  )}
                </Field>
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
            {submitting ? 'Creating...' : 'Create Hotel'}
          </button>
          <Link
            href="/dashboard/hotels"
            className="px-6 py-2.5 rounded-lg text-sm font-medium transition-all"
            style={{ background: 'var(--bg-elevated)', border: '1px solid var(--border)', color: 'var(--text-secondary)' }}
          >
            Cancel
          </Link>
        </div>
      </form>
    </div>
  );
}
