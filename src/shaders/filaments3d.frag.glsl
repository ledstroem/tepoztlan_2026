#version 300 es
precision highp float;

in float vActive;
in float vDepth01;
in float vBrightness;
in float vBrightnessEnergy;
in float vCoreEmission;
in float vHaloEmission;
in float vGoldBuild;
in float vAlpha;
in float vGlow;
uniform float uCoreOpacity3D, uDepthAttenuation3D, uDepthTestedGlowStrength;
uniform float uOpeningBronzeColour3D, uEnergeticBronzeGold3D;
uniform float uMiddleSoftGold3D, uEnergeticChampagne3D, uPeakSoftGold3D;
uniform float uNearDepthGoldShift3D, uHaloGoldSoftness3D;
out vec4 outColor;

void main(){
  if(vActive<0.01 || vAlpha<0.01) discard;
  vec3 bronzeMid=vec3(0.36,0.235,0.095);
  vec3 bronzePale=vec3(0.62,0.46,0.22);
  vec3 energeticGold=vec3(0.72,0.57,0.30);
  vec3 openingBronze=mix(bronzeMid,bronzePale,uOpeningBronzeColour3D);
  vec3 middleSoftGold=mix(openingBronze,vec3(0.70,0.52,0.24),uMiddleSoftGold3D);
  vec3 energeticChampagne=mix(middleSoftGold,vec3(0.88,0.70,0.38),uEnergeticChampagne3D);
  vec3 earlyGold=mix(openingBronze,middleSoftGold,smoothstep(0.0,0.55,vGoldBuild));
  vec3 filamentColour=mix(earlyGold,energeticChampagne,smoothstep(0.40,0.88,vGoldBuild));
  vec3 peakSoftGold=mix(energeticChampagne,vec3(1.0,0.86,0.58),uPeakSoftGold3D);
  filamentColour=mix(filamentColour,peakSoftGold,smoothstep(0.82,1.0,vGoldBuild));
  vec3 depthColour=mix(filamentColour,mix(filamentColour,peakSoftGold,uNearDepthGoldShift3D*0.18),vDepth01*vGoldBuild);
  vec3 haloColour=mix(depthColour,vec3(1.0,0.86,0.62),uHaloGoldSoftness3D);
  float attenuation=mix(1.0-uDepthAttenuation3D,1.0,vDepth01);
  if(vGlow>0.5){
    float glowAlpha=vAlpha*uDepthTestedGlowStrength*attenuation*vHaloEmission;
    outColor=vec4(haloColour*1.18,glowAlpha);
  }else{
    float coreAlpha=vAlpha*uCoreOpacity3D*attenuation*vCoreEmission;
    outColor=vec4(depthColour,coreAlpha);
  }
}
