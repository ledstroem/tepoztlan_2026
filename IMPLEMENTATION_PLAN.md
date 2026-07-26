# Implementation plan

1. Set up a Vite + TypeScript app with a single full-screen WebGL2 triangle and shader modules loaded as raw GLSL.
2. Implement deterministic timeline/easing and parameter presets, then build the fragment shader around deforming off-screen circle branches into a shifted reciprocal four-point curve.
3. Add a compact collapsible control panel, keyboard controls, fixed-progress query support, fullscreen, hidden reference comparison, and MediaRecorder capture.
4. Add documentation and unit tests for the math/control defaults.
5. Install dependencies, run tests/build, launch the dev server, inspect rendered checkpoints, and fix any runtime or shader issues.
