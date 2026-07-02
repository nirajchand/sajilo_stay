'use client';

import { useState, useEffect, useRef, useCallback } from 'react';
import { MapContainer, TileLayer, Marker, useMapEvents, useMap } from 'react-leaflet';
import type { Marker as LeafletMarker } from 'leaflet';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';

const DEFAULT_CENTER: [number, number] = [27.7172, 85.324]; // Kathmandu

// CDN-hosted icons avoid webpack asset-path issues with Leaflet
const PIN_ICON = L.icon({
  iconUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon.png',
  iconRetinaUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-icon-2x.png',
  shadowUrl: 'https://unpkg.com/leaflet@1.9.4/dist/images/marker-shadow.png',
  iconSize: [25, 41],
  iconAnchor: [12, 41],
  shadowSize: [41, 41],
});

interface NominatimResult {
  lat: string;
  lon: string;
  display_name: string;
}

export interface MapPickerProps {
  initialLat?: number;
  initialLng?: number;
  onLocationChange: (lat: number, lng: number, address: string) => void;
}

function ClickLayer({ onPick }: { onPick: (lat: number, lng: number) => void }) {
  useMapEvents({ click: (e) => onPick(e.latlng.lat, e.latlng.lng) });
  return null;
}

function FlyTo({ lat, lng, token }: { lat: number; lng: number; token: number }) {
  const map = useMap();
  const prev = useRef(0);
  useEffect(() => {
    if (token > 0 && token !== prev.current) {
      prev.current = token;
      map.flyTo([lat, lng], 15, { duration: 1.0 });
    }
  }, [map, lat, lng, token]);
  return null;
}

export default function MapPickerInner({ initialLat, initialLng, onLocationChange }: MapPickerProps) {
  const hasInit = !!initialLat && !!initialLng;

  const [lat, setLat] = useState(hasInit ? initialLat! : DEFAULT_CENTER[0]);
  const [lng, setLng] = useState(hasInit ? initialLng! : DEFAULT_CENTER[1]);
  const [flyToken, setFlyToken] = useState(0);

  const [geocoding, setGeocoding] = useState(false);
  const [query, setQuery] = useState('');
  const [results, setResults] = useState<NominatimResult[]>([]);
  const [searching, setSearching] = useState(false);
  const [showDrop, setShowDrop] = useState(false);

  const markerRef = useRef<LeafletMarker>(null);

  const reverseGeocode = useCallback(async (lat: number, lng: number) => {
    setGeocoding(true);
    try {
      const res = await fetch(
        `https://nominatim.openstreetmap.org/reverse?lat=${lat}&lon=${lng}&format=json`,
        { headers: { 'Accept-Language': 'en', 'User-Agent': 'SajiloAdmin/1.0' } }
      );
      const data = await res.json();
      onLocationChange(lat, lng, data.display_name ?? `${lat.toFixed(5)}, ${lng.toFixed(5)}`);
    } catch {
      onLocationChange(lat, lng, `${lat.toFixed(5)}, ${lng.toFixed(5)}`);
    } finally {
      setGeocoding(false);
    }
  }, [onLocationChange]);

  function pickLocation(newLat: number, newLng: number) {
    setLat(newLat);
    setLng(newLng);
    reverseGeocode(newLat, newLng);
  }

  async function doSearch() {
    const q = query.trim();
    if (!q) return;
    setSearching(true);
    setShowDrop(true);
    setResults([]);
    try {
      const res = await fetch(
        `https://nominatim.openstreetmap.org/search?q=${encodeURIComponent(q)}&format=json&limit=5`,
        { headers: { 'Accept-Language': 'en', 'User-Agent': 'SajiloAdmin/1.0' } }
      );
      setResults(await res.json());
    } catch {
      setResults([]);
    } finally {
      setSearching(false);
    }
  }

  function selectResult(r: NominatimResult) {
    const newLat = parseFloat(r.lat);
    const newLng = parseFloat(r.lon);
    setLat(newLat);
    setLng(newLng);
    setFlyToken(Date.now());
    setQuery(r.display_name);
    setShowDrop(false);
    onLocationChange(newLat, newLng, r.display_name);
  }

  useEffect(() => {
    if (hasInit) reverseGeocode(initialLat!, initialLng!);
  }, []); // eslint-disable-line react-hooks/exhaustive-deps

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 10 }}>
      {/* Search bar */}
      <div style={{ position: 'relative' }}>
        <div style={{ display: 'flex', gap: 8 }}>
          <input
            type="text"
            value={query}
            placeholder="Search for a city, place, or address..."
            onChange={(e) => { setQuery(e.target.value); if (!e.target.value) setShowDrop(false); }}
            onKeyDown={(e) => { if (e.key === 'Enter') { e.preventDefault(); doSearch(); } }}
            onBlur={() => setTimeout(() => setShowDrop(false), 160)}
            style={{
              flex: 1,
              padding: '10px 12px',
              borderRadius: 10,
              border: '1px solid var(--border)',
              background: 'var(--bg-input)',
              color: 'var(--text-primary)',
              fontSize: 13,
              outline: 'none',
            }}
            onFocus={(e) => (e.currentTarget.style.borderColor = 'var(--border-focus)')}
          />
          <button
            type="button"
            onClick={doSearch}
            disabled={searching || !query.trim()}
            style={{
              padding: '10px 16px',
              borderRadius: 10,
              background: 'var(--accent)',
              color: '#fff',
              fontSize: 13,
              fontWeight: 500,
              border: 'none',
              cursor: searching || !query.trim() ? 'not-allowed' : 'pointer',
              opacity: searching || !query.trim() ? 0.5 : 1,
              display: 'flex',
              alignItems: 'center',
              gap: 6,
            }}
          >
            {searching ? (
              <span>Searching...</span>
            ) : (
              <>
                <svg width="14" height="14" fill="none" stroke="currentColor" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2.5} d="M21 21l-6-6m2-5a7 7 0 11-14 0 7 7 0 0114 0z" />
                </svg>
                Search
              </>
            )}
          </button>
        </div>

        {/* Dropdown */}
        {showDrop && (
          <div
            style={{
              position: 'absolute',
              top: '100%',
              left: 0,
              right: 0,
              marginTop: 4,
              borderRadius: 12,
              overflow: 'hidden',
              background: 'var(--bg-elevated)',
              border: '1px solid var(--border)',
              boxShadow: '0 16px 40px rgba(0,0,0,0.4)',
              zIndex: 1000,
            }}
          >
            {searching && (
              <div style={{ padding: '12px 16px', fontSize: 13, color: 'var(--text-muted)' }}>
                Searching...
              </div>
            )}
            {!searching && results.length === 0 && (
              <div style={{ padding: '12px 16px', fontSize: 13, color: 'var(--text-muted)' }}>
                No results found
              </div>
            )}
            {results.map((r, i) => (
              <button
                key={i}
                type="button"
                onMouseDown={() => selectResult(r)}
                style={{
                  width: '100%',
                  textAlign: 'left',
                  padding: '11px 16px',
                  fontSize: 13,
                  color: 'var(--text-primary)',
                  background: 'transparent',
                  border: 'none',
                  borderBottom: i < results.length - 1 ? '1px solid var(--border)' : 'none',
                  cursor: 'pointer',
                  display: 'flex',
                  alignItems: 'flex-start',
                  gap: 8,
                }}
                onMouseEnter={(e) => (e.currentTarget.style.background = 'rgba(79,110,247,0.08)')}
                onMouseLeave={(e) => (e.currentTarget.style.background = 'transparent')}
              >
                <svg style={{ flexShrink: 0, marginTop: 1 }} width="13" height="13" fill="none" stroke="var(--accent)" viewBox="0 0 24 24">
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a2 2 0 01-2.828 0l-4.243-4.243a8 8 0 1111.314 0z" />
                  <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
                </svg>
                <span style={{ lineHeight: 1.4 }}>{r.display_name}</span>
              </button>
            ))}
          </div>
        )}
      </div>

      {/* Map */}
      <div style={{ borderRadius: 14, overflow: 'hidden', position: 'relative' }}>
        <MapContainer
          center={[lat, lng]}
          zoom={hasInit ? 15 : 12}
          style={{ height: 320, width: '100%' }}
          scrollWheelZoom
        >
          <TileLayer
            attribution='&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors'
            url="https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png"
          />
          <ClickLayer onPick={pickLocation} />
          <FlyTo lat={lat} lng={lng} token={flyToken} />
          <Marker
            position={[lat, lng]}
            icon={PIN_ICON}
            draggable
            eventHandlers={{
              dragend() {
                const m = markerRef.current;
                if (m) {
                  const p = m.getLatLng();
                  pickLocation(p.lat, p.lng);
                }
              },
            }}
            ref={markerRef}
          />
        </MapContainer>

        {/* Hint */}
        <div style={{
          position: 'absolute', bottom: 12, left: '50%', transform: 'translateX(-50%)',
          background: 'rgba(0,0,0,0.6)', color: '#fff', fontSize: 11,
          padding: '5px 12px', borderRadius: 999, pointerEvents: 'none',
          zIndex: 500, whiteSpace: 'nowrap',
        }}>
          Click map or drag pin to set location
        </div>

        {geocoding && (
          <div style={{
            position: 'absolute', top: 12, right: 12,
            background: 'rgba(0,0,0,0.65)', color: '#fff', fontSize: 11,
            padding: '5px 12px', borderRadius: 999, zIndex: 500,
          }}>
            Getting address...
          </div>
        )}
      </div>

      {/* Coords */}
      <div style={{ display: 'flex', alignItems: 'center', gap: 6, fontSize: 11, color: 'var(--text-muted)' }}>
        <svg width="12" height="12" fill="none" stroke="currentColor" viewBox="0 0 24 24">
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M17.657 16.657L13.414 20.9a2 2 0 01-2.828 0l-4.243-4.243a8 8 0 1111.314 0z" />
          <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={2} d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
        </svg>
        Lat {lat.toFixed(6)} · Lng {lng.toFixed(6)}
      </div>
    </div>
  );
}
