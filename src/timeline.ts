import { clamp01, smootherstep } from './math/easing';
export class Timeline { progress=0; playing=true; speed=1; duration=16; private last=performance.now();
  tick(now=performance.now()){ const dt=Math.min(.1,Math.max(0,(now-this.last)/1000)); this.last=now; if(this.playing) this.progress=clamp01(this.progress+dt*this.speed/this.duration); return this.progress; }
  setProgress(v:number){this.progress=clamp01(v); this.last=performance.now();} reset(){this.setProgress(0);this.playing=true;} eased(){return smootherstep(this.progress);}
}
