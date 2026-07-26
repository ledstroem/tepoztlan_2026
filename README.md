# Breakthrough Field

A plain TypeScript + Vite + WebGL2 generative artwork. The default 34-second “Full breakthrough and spectral ecstasy” sequence lets two independent, imperfect circles accumulate motion, converge into a golden reciprocal diamond, hold that attractor for four seconds, then unfold it into a volumetric spectral field.

## Install and run

```sh
npm install
npm run dev
```

Open the local Vite URL. For a deterministic still, use `?progress=0`, `?progress=0.5`, or `?progress=1`. Named inspection points include `?phase=diamond`, `?phase=spectral-emergence`, `?phase=spectral-expansion`, and `?phase=ecstasy`.

## Controls

The compact panel exposes timeline, circle, reciprocal peak, motion, line reveal, travelling energy, coupling/settling, depth, light, spectral ecstasy, quality, adaptive-resolution, counter-rotation, reduced intensity, and reference-overlay settings. Space toggles play/pause, R restarts, F requests fullscreen, H hides the panel, O toggles the reference overlay, and 1/2/3 jump to the initial, middle, and peak frames.

The overlay is development-only and hidden by default. It does not contribute to the shader artwork.

## Recording

Record uses `canvas.captureStream(60)` and tries VP9 WebM, then VP8/WebM. The downloaded file can be converted with ffmpeg:

```sh
ffmpeg -i breakthrough-16s.webm -c:v libx264 -pix_fmt yuv420p breakthrough.mp4
```

## Mathematical model

The fragment shader uses aspect-corrected coordinates. At the start, each filament samples an inward-facing branch of `(x-c)^2+y^2=R^2` or its reflection, with smooth multi-harmonic radial perturbations and independent phase. A fixed 96-iteration loop progressively reveals lines from the initial count to the peak count. Build-up, energy, coupling, morph, collapse, and settle are separate overlapping envelopes, so the circular geometry remains dominant until late in the timeline. Filament offsets expand slightly during the active phase, then collapse from `startSpread` toward `endSpread` while differential rotation and travelling energy bands make motion legible.

At the peak the circle branch becomes the shifted reciprocal curve `x = epsilon * (A - |y|) / (|y| + epsilon)`, reflected over both axes. The default morph window is progress 0.68–0.91, after the high-energy pre-convergence phase. The diamond completes at 18 seconds and holds for 4 seconds. Its analytic derivative supplies an approximate normal distance for antialiased core and halo lines. Depth-dependent parallax and scale grow through the rotating build-up and fold back together during convergence.

After the hold, the fragment shader uses a separate spectral timeline: 2 seconds of white-gold spectral emergence, 7 seconds of expansion, and a 3-second ecstatic hold. A fixed 28-sample maximum loop samples front and rear depth layers. Anisotropic radius warps, radial wavefronts, and horizontal/vertical/diagonal sheet families create related bands that cross the screen and continue beyond its edges. Samples are composited emissively with modest absorption, and a compact wavelength-to-RGB approximation keeps the ordering violet through red while the central source stays white-gold.

## Parameters and performance

`c` and `r` control the off-screen circles; `A` and `epsilon` control extent and reciprocal concavity. `omega0`, `omega1`, speed ratio, and counter-rotation control smooth independent acceleration. Initial/peak line counts and reveal softness control density. Base/peak imperfection, differential rotation, travelling energy frequency/speed, radial breathing, and pre-convergence energy drive the active middle phase. Convergence impulse and settling strength govern the late reorganisation. Spectral duration controls, expansion speed/acceleration, band frequency/softness/width, anisotropic XYZ scale, depth stretch, density, saturation, exposure, white-source strength, overlap whitening, wave deformation, pulse, camera drift, and residual diamond visibility tune the final field. Low/medium/high quality selects 9/16/24 spectral depth samples and changes the filament budget, while adaptive resolution reacts only after sustained frame-rate samples. Device pixel ratio is capped at 1.5.

WebGL2 is required. WebGPU is deliberately not used. If WebGL2 is unavailable, use a current browser and enable hardware acceleration. Resize is handled in the renderer without distorting the aspect-corrected coordinates.
