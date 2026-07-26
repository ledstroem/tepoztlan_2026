export const smootherstep = (s: number) => { const x = Math.max(0, Math.min(1, s)); return x*x*x*(x*(x*6-15)+10); };
export const clamp01 = (v: number) => Math.max(0, Math.min(1, v));
