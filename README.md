# Breakthrough Field

Breakthrough Field is a procedural WebGL2 generative visualisation of a
phenomenological sequence: sparse rotating strands gather energy, pass through
depth, converge into a luminous reciprocal peak, unfold into a moving rainbow
field, and resolve into soft light before fading to black.

The imagery is generated at runtime by GLSL shaders. The reference images are
development-only comparisons and are never rendered as the artwork itself.

## Preview

![Breakthrough Field preview](docs/images/peak.png)

## Overview

The default sequence moves through these broad stages:

- a calm, sparse pair of pale-bronze rotating strand fields;
- accelerating rotation, increasing brightness, and stronger three-dimensional
  projection;
- gradual strand introduction and delayed departures from the circular paths;
- convergence into a central golden reciprocal four-point diamond;
- a still diamond hold and fade;
- a vivid moving rainbow field;
- a soft translucent yellow-white-gold field over darkness;
- a final hold, fade to black, and still black endpoint.

## Technology

- TypeScript
- Vite
- WebGL2
- GLSL ES 3.00 fragment and vertex shaders
- Vitest for deterministic tests
- Browser-native `MediaRecorder` for canvas recording

No third-party GUI library is used; the control panel is built in
`src/controls.ts`.

## Requirements

Install a current Node.js release with npm. The repository does not enforce a
specific Node.js version. Node.js 20 or newer is a reasonable recommendation.

Use a browser with WebGL2 support and hardware acceleration enabled when
possible. WebGPU is not required.

## Installation

```sh
git clone https://github.com/ledstroem/tepoztlan_2026.git
cd tepoztlan-repelication/breakthrough_2
npm install
```

If this package is already checked out inside a larger repository, change into
this project directory instead of cloning it again.

## Running locally

```sh
npm run dev
```

Open the local URL printed by Vite. The configured development server uses
`127.0.0.1:5174` when that port is available.

For deterministic inspection, use a fixed progress value:

```text
http://127.0.0.1:5174/?progress=0.5
```

Supported named inspection phases are `diamond`, `spectral-emergence`,
`spectral-expansion`, `ecstasy`, and `soft-light`:

```text
http://127.0.0.1:5174/?phase=diamond
```

Fixed-progress and named-phase views pause playback. The normal page starts
playing automatically.

## Production build

```sh
npm run build
```

This runs TypeScript checking and creates the production bundle in `dist/`.
There is no `preview` script in `package.json`; use the development server or
serve `dist/` with the static hosting setup used by your environment.

## Tests and checks

The repository currently defines these npm scripts:

```sh
npm test
npm run build
```

`npm test` runs the Vitest suite. The build performs the TypeScript project
check before bundling with Vite. No separate lint or typecheck script is
defined.

## Controls

The on-screen panel provides controls for:

- timeline, playback speed, and phase timing;
- initial and peak geometry;
- strand population, rotation, reveal, and travelling energy;
- convergence, settling, and the reciprocal peak;
- true 3D depth, perspective, width, brightness, and occlusion;
- delayed strand departures;
- the spectral rainbow field;
- final soft light and the fade-to-black ending;
- quality, adaptive resolution, reduced intensity, and counter-rotation;
- reference overlay comparison.

Keyboard shortcuts are shown in the panel: Space toggles playback, R restarts,
F requests fullscreen, H hides the controls, O toggles the reference overlay,
and 1/2/3 jump to the start, midpoint, and final progress values.

The Record button captures the canvas at 60 fps using WebM when supported.

## Animation structure

| Phase | Description | Main implementation |
| --- | --- | --- |
| Opening and rotation | Sparse bronze strands rotate around off-screen centres. | `src/shaders/filaments3d.vert.glsl`, `src/shaders/filaments3d.frag.glsl` |
| Build-up and depth | Strand count, brightness, tilt, orbit depth, and perspective increase. | `src/shaders/filaments3d.vert.glsl` |
| Departures | Selected strands peel away on delayed three-dimensional trajectories. | `src/shaders/filaments3d.vert.glsl` |
| Convergence and diamond | The rotating field reorganises into the reciprocal peak and holds still. | `src/shaders/breakthrough.frag.glsl` |
| Rainbow field | Spectral sheets emerge, expand, move, and hold. | `src/shaders/breakthrough.frag.glsl` |
| Soft light and ending | The rainbow resolves into gold-white light, holds, fades, and becomes black. | `src/shaders/breakthrough.frag.glsl` |

The total duration and default parameter values are defined in
`src/math/parameters.ts`. `src/timeline.ts` advances normalized progress;
`src/main.ts` maps that progress to playback, query-parameter checkpoints, and
recording behavior.

## Project structure

```text
.
├── docs/
│   └── images/                    Documentation previews and ignored captures
├── public/
│   └── reference/                 Optional overlay reference images
├── src/
│   ├── controls.ts                Control-panel construction and bindings
│   ├── main.ts                    Application entry point and animation loop
│   ├── math/
│   │   ├── easing.ts              Deterministic easing functions
│   │   └── parameters.ts          Defaults, timeline values, and quality tiers
│   ├── recorder.ts                Canvas recording support
│   ├── renderer.ts                WebGL2 programs, buffers, uniforms, and passes
│   ├── shaders/
│   │   ├── breakthrough.frag.glsl Full-screen field, convergence, rainbow, light
│   │   ├── filaments3d.frag.glsl  Filament core and glow appearance
│   │   ├── filaments3d.vert.glsl  Instanced 3D strand geometry
│   │   └── fullscreen.vert.glsl   Full-screen triangle vertex shader
│   ├── styles.css                 Control-panel and page styling
│   ├── timeline.ts                Normalized playback timeline
│   └── vite-env.d.ts              Vite type declarations
├── tests/
│   ├── easing.test.ts             Easing tests
│   └── parameters.test.ts         Default and schedule tests
├── index.html                     HTML entry document
├── package.json                   Scripts and dependencies
├── tsconfig.json                  TypeScript configuration
└── vite.config.ts                 Vite development-server configuration
```

## Rendering architecture

`src/renderer.ts` creates a WebGL2 context, compiles the full-screen and
filament shader programs, and owns their buffers and uniforms. The main pass
draws a full-screen triangle through `breakthrough.frag.glsl`. That shader
contains the convergence, diamond, spectral field, final light, tone mapping,
and phase gates.

Before convergence, a separate instanced triangle-strip pass draws the circular
filament strands. `filaments3d.vert.glsl` computes shared integrated rotation,
ring-plane orientation, orbit depth, departures, perspective, and projected
width. The core pass uses depth testing and depth writes; the glow pass uses
depth testing without writing depth and blends locally over the cores.

The final soft light is procedural and spatially nonuniform. It is emitted in
the full-screen shader rather than through a separate persistent bloom buffer.
The ending multiplies that existing contribution by a smootherstep fade and
forces the linear output to zero at the completed black time, so later frames
remain black and scrubbing does not retain framebuffer state.

## Performance notes

The quality selector provides low, medium, and high filament budgets and
spectral sample counts. Adaptive resolution can lower or raise the render
scale after sustained frame-rate measurements. Medium quality is the default.

Most expensive work stays in the fragment shader; there is no CPU particle
system. WebGL2 hardware acceleration is recommended for smooth large-canvas
playback, but the application does not require WebGPU.

## Troubleshooting

### Blank or black canvas

Check the browser console and verify that the page is using the Vite URL. A
black frame at the end of the timeline is intentional; a black opening with no
strands usually indicates a rendering or WebGL initialization problem.

### WebGL2 unavailable

Use a current browser and enable hardware acceleration. The renderer reports a
clear WebGL2 error when the context cannot be created.

### Low frame rate

Select low or medium quality, leave adaptive resolution enabled, and close
other GPU-heavy pages. Large device-pixel-ratio displays are capped by the
renderer, but browser hardware acceleration still matters.

### Dependencies fail to install

Use a current Node.js/npm installation, remove an incomplete `node_modules/`
directory, and run `npm install` again. The committed `package-lock.json`
should be used by npm for repeatable dependency resolution.

### Development server port already in use

Vite reports the alternate local port it selects. Open that printed URL, or
stop the process using port 5174 before restarting the server.

### Reference image 404

Runtime overlay images live at `public/reference/start.png` and
`public/reference/peak.png`, and are requested as `/reference/start.png` and
`/reference/peak.png`. Documentation previews live separately under
`docs/images/` and are not runtime URLs.

## Development notes

Adjust default phase values in `src/math/parameters.ts`; keep the derived
schedule test in `tests/parameters.test.ts` aligned with any intentional
timeline change. Modify filament geometry and depth in the `filaments3d` GLSL
pair, and modify convergence, spectral, final-light, or fade behavior in
`breakthrough.frag.glsl`.

Keep later-phase contributions gated by their phase envelopes so spectral and
final-light output cannot leak into the opening. Use the control panel for
appearance experiments that do not need source changes, and preserve the
quality presets when tuning expensive shader loops.

Documentation previews belong in `docs/images/`. Runtime reference assets
belong in `public/reference/`; they are optional comparison overlays and are
not part of the procedural artwork.

## License

No license file is currently included in this repository.
