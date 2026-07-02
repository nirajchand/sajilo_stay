import dynamic from 'next/dynamic';
import type { MapPickerProps } from './MapPickerInner';

const MapPickerInner = dynamic(() => import('./MapPickerInner'), {
  ssr: false,
  loading: () => (
    <div
      style={{
        height: 370,
        borderRadius: 14,
        display: 'flex',
        alignItems: 'center',
        justifyContent: 'center',
        flexDirection: 'column',
        gap: 10,
        background: 'var(--bg-elevated)',
        border: '1px solid var(--border)',
      }}
    >
      <svg width="28" height="28" fill="none" stroke="var(--text-muted)" viewBox="0 0 24 24">
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
          d="M17.657 16.657L13.414 20.9a2 2 0 01-2.828 0l-4.243-4.243a8 8 0 1111.314 0z" />
        <path strokeLinecap="round" strokeLinejoin="round" strokeWidth={1.5}
          d="M15 11a3 3 0 11-6 0 3 3 0 016 0z" />
      </svg>
      <span style={{ fontSize: 13, color: 'var(--text-muted)' }}>Loading map...</span>
    </div>
  ),
});

export function MapPicker(props: MapPickerProps) {
  return <MapPickerInner {...props} />;
}
