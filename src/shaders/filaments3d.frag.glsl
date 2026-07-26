#version 300 es
precision highp float;

in float vActive;
in float vDepth01;
in float vBrightness;
in float vAlpha;
in float vGlow;
uniform float uCoreOpacity3D, uDepthAttenuation3D, uDepthTestedGlowStrength;
out vec4 outColor;

void main(){
  if(vActive<0.01 || vAlpha<0.01) discard;
  vec3 bronze=mix(vec3(0.30,0.19,0.075),vec3(0.58,0.40,0.17),vBrightness*0.62);
  vec3 pale=mix(bronze,vec3(0.82,0.62,0.32),smoothstep(0.72,1.0,vBrightness));
  float attenuation=mix(1.0-uDepthAttenuation3D,1.0,vDepth01);
  if(vGlow>0.5){
    float glowAlpha=vAlpha*uDepthTestedGlowStrength*attenuation;
    outColor=vec4(pale*1.35,glowAlpha);
  }else{
    float coreAlpha=vAlpha*uCoreOpacity3D*attenuation;
    outColor=vec4(pale,coreAlpha);
  }
}
