import './styles.css';
import { defaults, type Params } from './math/parameters';
import { Renderer } from './renderer';
import { Timeline } from './timeline';
import { Recorder } from './recorder';
import { mountControls } from './controls';
const canvas=document.querySelector<HTMLCanvasElement>('#canvas')!;const app=document.querySelector<HTMLElement>('#app')!;
try{
  const params:Params={...defaults}, query=new URLSearchParams(location.search);const phase=query.get('phase');const phaseTimes:Record<string,number>={diamond:params.diamondCompleteTime, 'spectral-emergence':params.diamondCompleteTime+params.diamondHoldDuration+params.spectralEmergenceDuration*.5, 'spectral-expansion':params.diamondCompleteTime+params.diamondHoldDuration+params.spectralEmergenceDuration+params.spectralExpansionDuration*.5, ecstasy:params.duration-params.ecstaticHoldDuration*.5};const fixed=query.get('progress');if(phase&&phaseTimes[phase]!==undefined)params.progress=Math.max(0,Math.min(1,phaseTimes[phase]/params.duration));else if(fixed!==null)params.progress=Math.max(0,Math.min(1,Number(fixed)||0));
  const timeline=new Timeline();timeline.duration=params.duration;timeline.speed=params.playSpeed;timeline.setProgress(params.progress);if(fixed!==null||phase)timeline.playing=false;
  const renderer=new Renderer(canvas), recorder=new Recorder();let shown=true;let last=performance.now(), fps=60, adjustAt=performance.now();
  const ui=mountControls(app,params,timeline,recorder,canvas,()=>{timeline.duration=params.duration;timeline.speed=params.playSpeed;});
  const toggle=()=>{shown=!shown;ui.panel.classList.toggle('hidden',!shown)};const overlay=()=>{params.overlay=!params.overlay;ui.setOverlay(params.overlay)};
  addEventListener('keydown',e=>{if(e.target instanceof HTMLInputElement)return;const k=e.key.toLowerCase();if(k===' ') {e.preventDefault();timeline.playing=!timeline.playing;}else if(k==='r'){timeline.reset()}else if(k==='f'){document.documentElement.requestFullscreen?.()}else if(k==='h'){toggle()}else if(k==='o'){overlay()}else if(k==='1'){timeline.setProgress(0);params.progress=0}else if(k==='2'){timeline.setProgress(.5);params.progress=.5}else if(k==='3'){timeline.setProgress(1);params.progress=1}});
  const frame=(now:number)=>{fps=fps*.94+(.06*1000/Math.max(1,now-last));last=now;timeline.tick(now);params.progress=timeline.progress;if(recorder.active&&timeline.progress>=1){timeline.playing=false;recorder.stop()}renderer.render(now/1000,params);if(params.adaptive&&now-adjustAt>1800){if(fps<48)renderer.setScale(.86);else if(fps>58)renderer.setScale(1.05);adjustAt=now;}requestAnimationFrame(frame)};requestAnimationFrame(frame);
}catch(error){const message=error instanceof Error?error.message:String(error);app.innerHTML=`<div class="error">${message}</div>`;console.error(error)}
