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
uniform float uNearDiamondColourInfluence3D, uNearDepthGoldShift3D, uHaloGoldSoftness3D;
out vec4 outColor;

void main(){
  if(vActive<0.01 || vAlpha<0.01) discard;
  vec3 bronzeMid=vec3(0.36,0.235,0.095);
  vec3 bronzePale=vec3(0.62,0.46,0.22);
  vec3 openingBronze=mix(bronzeMid,bronzePale,uOpeningBronzeColour3D);
  vec3 middleSoftGold=mix(openingBronze,vec3(0.78,0.64,0.38),uMiddleSoftGold3D);
  vec3 energeticChampagne=mix(middleSoftGold,vec3(0.91,0.78,0.50),uEnergeticChampagne3D);
  vec3 peakSoftGold=mix(energeticChampagne,vec3(1.0,0.86,0.58),uPeakSoftGold3D);
  vec3 nearDiamondGold=mix(energeticChampagne,peakSoftGold,smoothstep(0.82,1.0,vGoldBuild));
  vec3 softGoldTarget=mix(middleSoftGold,nearDiamondGold,uNearDiamondColourInfluence3D);
  vec3 filamentColour=mix(openingBronze,softGoldTarget,vGoldBuild);
  vec3 depthColour=mix(filamentColour,mix(filamentColour,peakSoftGold,uNearDepthGoldShift3D*0.12),vDepth01*vGoldBuild);
  vec3 haloColour=mix(depthColour,vec3(1.0,0.90,0.70),uHaloGoldSoftness3D*(0.55+0.45*vGoldBuild));
  float attenuation=mix(1.0-uDepthAttenuation3D,1.0,vDepth01);
  if(vGlow>0.5){
    float glowAlpha=vAlpha*uDepthTestedGlowStrength*attenuation*vHaloEmission*0.82;
    outColor=vec4(haloColour*1.10,glowAlpha);
  }else{
    float coreAlpha=vAlpha*uCoreOpacity3D*attenuation*vCoreEmission;
    outColor=vec4(depthColour,coreAlpha);
  }
}
