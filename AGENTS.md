# Breakthrough Field

## Purpose

This is a procedural generative-art recreation of two rotating off-screen filament fields deforming into a luminous reciprocal four-point peak.

## Commands

- `npm install` — install development dependencies.
- `npm run dev` — run the Vite development server.
- `npm run build` — type-check and produce the production bundle.
- `npm test` — run the deterministic math tests.

## Constraints

The final imagery must remain procedural: reference PNGs are for optional development comparison only and are never rendered as artwork. WebGL2 is the default backend; do not make WebGPU a requirement. Keep expensive work in the fragment shader, avoid CPU particle systems and per-frame allocations, and target smooth 1920×1080 rendering.
