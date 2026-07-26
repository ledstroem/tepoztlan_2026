export class Recorder { private recorder?:MediaRecorder; private chunks:Blob[]=[];
  start(canvas:HTMLCanvasElement,duration:number,onDone:()=>void){if(this.recorder)return;const stream=canvas.captureStream(60);const types=['video/webm;codecs=vp9','video/webm;codecs=vp8','video/webm'];const type=types.find(MediaRecorder.isTypeSupported);if(!type){alert('This browser cannot record WebM.');return;}this.chunks=[];this.recorder=new MediaRecorder(stream,{mimeType:type,videoBitsPerSecond:12000000});this.recorder.ondataavailable=e=>{if(e.data.size)this.chunks.push(e.data)};this.recorder.onstop=()=>{const a=document.createElement('a');a.href=URL.createObjectURL(new Blob(this.chunks,{type}));a.download=`breakthrough-${duration}s.webm`;a.click();this.recorder=undefined;onDone();};this.recorder.start(1000);}
  stop(){this.recorder?.stop();}
  get active(){return !!this.recorder;}
}
