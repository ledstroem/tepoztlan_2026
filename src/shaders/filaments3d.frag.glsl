#version 300 es
precision highp float;

in float vActive;
in float vDepth01;
in float vBrightness;
in float vBrightnessEnergy;
in float vCoreEmission;
in float vHaloEmission;
in float vAlpha;
in float vGlow;
uniform float uCoreOpacity3D, uDepthAttenuation3D, uDepthTestedGlowStrength;
uniform float uOpeningBronzeColour3D, uEnergeticBronzeGold3D;
out vec4 outColor;

void main(){
  if(vActive<0.01 || vAlpha<0.01) discard;
  vec3 bronzeMid=vec3(0.36,0.235,0.095);
  vec3 bronzePale=vec3(0.62,0.46,0.22);
  vec3 energeticGold=vec3(0.72,0.57,0.30);
  vec3 openingBronze=mix(bronzeMid,bronzePale,uOpeningBronzeColour3D);
  vec3 energeticBronze=mix(bronzePale,energeticGold,uEnergeticBronzeGold3D);
  vec3 filamentColour=mix(openingBronze,energeticBronze,pow(vBrightnessEnergy,1.1));
  vec3 pale=mix(filamentColour,vec3(0.86,0.73,0.48),smoothstep(0.86,1.0,vBrightnessEnergy)*0.28);
  float attenuation=mix(1.0-uDepthAttenuation3D,1.0,vDepth01);
  if(vGlow>0.5){
    float glowAlpha=vAlpha*uDepthTestedGlowStrength*attenuation*vHaloEmission;
    outColor=vec4(pale*1.25,glowAlpha);
  }else{
    float coreAlpha=vAlpha*uCoreOpacity3D*attenuation*vCoreEmission;
    outColor=vec4(pale,coreAlpha);
  }
}
