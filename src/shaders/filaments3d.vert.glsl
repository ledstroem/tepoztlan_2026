#version 300 es
precision highp float;

layout(location=0) in float aTheta;
layout(location=1) in float aSide;

uniform vec2 uResolution;
uniform float uProgress, uDuration, uDiamondCompleteTime, uC, uR, uFilaments;
uniform float uInitialLines, uPeakLines, uRevealSoftness, uOmega0, uOmega1, uSpeedRatio, uCounterRotation;
uniform float uBaseImperfection, uDifferentialRotation, uBrightnessLandmarkStrength;
uniform float uDepthIntroductionTime, uMaxPlaneTilt, uPlaneTiltVariation3D, uBaseDepthSpread3D, uOrbitZAmplitude, uSecondaryZAmplitude, uPerspectiveStrength3D;
uniform float uNearWidthScale3D, uFarWidthScale3D, uNearBrightnessScale3D, uFarBrightnessScale3D, uDepthAttenuation3D, uCoreOpacity3D;
uniform float uInitialStripWidth3D, uEnergeticStripWidth3D, uInitialGlowScale3D, uEnergeticGlowScale3D;
uniform float uInitialCoreEmission3D, uPeakCoreEmission3D, uInitialHaloEmission3D, uPeakHaloEmission3D;
uniform float uBrightnessRiseStartTime3D, uBrightnessRiseDuration3D, uBrightnessExponent3D;
uniform float uEnableDepartures, uDepartureEarliestTime, uDepartureLatestTime, uDepartureDuration, uDepartingStrandProportion, uStrongDepartureProportion;
uniform float uTangentContinuationStrength, uDepartureLength, uHorizontalBend, uVerticalBend, uZBend, uEndTaper, uSideContainment3D, uDepartureCollapseTiming;
uniform float uGlow;

out float vActive;
out float vDepth01;
out float vBrightness;
out float vBrightnessEnergy;
out float vCoreEmission;
out float vHaloEmission;
out float vAlpha;
out float vGlow;

const float PI=3.14159265359;
const float TAU=6.28318530718;
float hash(float n){return fract(sin(n*91.17)*43758.5453);}
float smoother(float x){return x*x*x*(x*(x*6.0-15.0)+10.0);}
float ramp(float a,float b,float x){return smoother(clamp((x-a)/max(b-a,0.0001),0.0,1.0));}
mat3 rx(float a){float c=cos(a),s=sin(a);return mat3(1,0,0,0,c,-s,0,s,c);}
mat3 ry(float a){float c=cos(a),s=sin(a);return mat3(c,0,s,0,1,0,-s,0,c);}
mat3 rz(float a){float c=cos(a),s=sin(a);return mat3(c,-s,0,s,c,0,0,0,1);}

float rotationIntegral(float t){
  float start=0.05*uDiamondCompleteTime;
  float end=0.73*uDiamondCompleteTime;
  float d=max(end-start,0.001);
  float x=clamp((t-start)/d,0.0,1.0);
  if(t<=start)return uOmega0*t;
  if(t<=end)return uOmega0*t+(uOmega1-uOmega0)*d*pow(x,2.7)/2.7;
  return uOmega0*t+(uOmega1-uOmega0)*(d/2.7+t-end);
}

vec3 ringPosition(float angle,vec3 centre,vec3 U,vec3 V,float radius,float phase,float seed1,float seed2,float imperfection,float zBase,float zAmp,float z2,float depthBuild){
  float local=angle-phase;
  float shape=0.42*sin(2.0*local+seed1)+0.27*sin(3.0*local+seed2)+0.19*sin(5.0*local+seed1*1.7);
  float r=radius*(1.0+imperfection*shape);
  float z=zBase+depthBuild*(zAmp*sin(local+seed1)+z2*sin(2.0*local+seed2));
  return centre+U*(r*cos(angle))+V*(r*sin(angle))+vec3(0.0,0.0,z);
}

void main(){
  float elapsed=clamp(uProgress,0.0,1.0)*uDuration;
  float s=clamp(elapsed/max(uDiamondCompleteTime,0.001),0.0,1.0);
  float depthBuild=smoother(clamp((elapsed-uDepthIntroductionTime)/5.0,0.0,1.0));
  float brightnessRaw=clamp((elapsed-uBrightnessRiseStartTime3D)/max(uBrightnessRiseDuration3D,0.001),0.0,1.0);
  float brightnessBuild=smoother(brightnessRaw);
  float brightnessEnergy=pow(brightnessBuild,max(uBrightnessExponent3D,0.1));
  float depthRemaining=1.0-smoother(clamp((s-0.68)/0.23,0.0,1.0));
  float preFade=1.0-smoother(clamp((s-0.62)/0.12,0.0,1.0));
  float morph=ramp(0.68,0.91,s);
  float departureRemaining=1.0-smoother(clamp((morph-uDepartureCollapseTiming)/max(1.0-uDepartureCollapseTiming,0.05),0.0,1.0));
  float build=ramp(0.08,0.66,s);
  float initialFraction=clamp(2.0*uInitialLines/max(uFilaments,1.0),0.03,1.0);
  float peakFraction=clamp(2.0*uPeakLines/max(uFilaments,1.0),initialFraction,1.0);
  float activeFraction=mix(initialFraction,peakFraction,0.5+0.5*build);
  float fi=float(gl_InstanceID);
  float n=(fi+0.5)/max(uFilaments,1.0);
  float side=mod(fi,2.0)*2.0-1.0;
  float rnd=hash(fi+12.7), rnd2=hash(fi*2.71+15.9), rnd3=hash(fi*4.13+7.1);
  float activation=smoothstep(hash(fi*1.73+4.7)-uRevealSoftness,hash(fi*1.73+4.7)+uRevealSoftness,activeFraction);
  float direction=side<0.0?1.0:mix(1.0,-1.0,uCounterRotation);
  float rate=side<0.0?1.0:uSpeedRatio;
  float zIdentity=n*2.0-1.0;
  float differential=1.0+uDifferentialRotation*(zIdentity+0.45*(rnd-0.5));
  float phase=rotationIntegral(elapsed)*TAU*rate*direction*differential;
  float tiltX=(rnd-0.5)*2.0*uMaxPlaneTilt*depthBuild*depthRemaining;
  float tiltY=(rnd2-0.5)*2.0*uMaxPlaneTilt*0.72*depthBuild*depthRemaining;
  float roll=(rnd3-0.5)*2.0*0.18*depthBuild*depthRemaining;
  mat3 plane=rz(roll)*ry(tiltY)*rx(tiltX);
  vec3 U=plane*vec3(1.0,0.0,0.0);
  vec3 V=plane*vec3(0.0,1.0,0.0);
  vec3 centre=vec3(side*uC,0.0,0.0);
  float baseDepth=zIdentity*uBaseDepthSpread3D*depthBuild*depthRemaining;
  float localTheta=aTheta-phase;
  vec3 orbit=ringPosition(aTheta,centre,U,V,uR,phase,rnd*TAU,rnd2*TAU,uBaseImperfection,baseDepth,uOrbitZAmplitude,uSecondaryZAmplitude,depthBuild*depthRemaining);
  float departureEligibility=smoothstep(1.0-uDepartingStrandProportion,1.0,rnd2);
  float strong=smoothstep(1.0-uStrongDepartureProportion,1.0,rnd3);
  float departureAmount=departureEligibility*(0.62+0.38*strong)*uEnableDepartures;
  float departureStart=mix(uDepartureEarliestTime,uDepartureLatestTime,hash(fi*5.17+9.1));
  float departure=smoother(clamp((elapsed-departureStart)/max(uDepartureDuration,0.1),0.0,1.0))*departureRemaining;
  float anchor=fract(phase+rnd*TAU/TAU)*TAU;
  float forward=fract((aTheta-anchor+TAU)/TAU);
  float section=smoother(clamp((forward-0.04)/0.18,0.0,1.0));
  vec3 p0=ringPosition(anchor,centre,U,V,uR,phase,rnd*TAU,rnd2*TAU,uBaseImperfection,baseDepth,uOrbitZAmplitude,uSecondaryZAmplitude,depthBuild*depthRemaining);
  vec3 pPrev=ringPosition(anchor-0.02,centre,U,V,uR,phase,rnd*TAU,rnd2*TAU,uBaseImperfection,baseDepth,uOrbitZAmplitude,uSecondaryZAmplitude,depthBuild*depthRemaining);
  vec3 pNext=ringPosition(anchor+0.02,centre,U,V,uR,phase,rnd*TAU,rnd2*TAU,uBaseImperfection,baseDepth,uOrbitZAmplitude,uSecondaryZAmplitude,depthBuild*depthRemaining);
  vec3 tangent=normalize(pNext-pPrev);
  vec3 C1=p0+tangent*uTangentContinuationStrength;
  vec3 outward=vec3(side,0.16*(rnd-0.5),0.0);
  vec3 C2=C1+outward*uHorizontalBend+vec3(0.0,(rnd2-0.5)*uVerticalBend,uZBend*(rnd3-0.5));
  vec3 P1=C2+vec3(side*uDepartureLength, (rnd-0.5)*uVerticalBend*0.8, (rnd2-0.5)*uZBend);
  float oneMinus=1.0-forward;
  vec3 departurePoint=oneMinus*oneMinus*oneMinus*p0+3.0*oneMinus*oneMinus*forward*C1+3.0*oneMinus*forward*forward*C2+forward*forward*forward*P1;
  float departureBlend=departure*departureAmount*section;
  vec3 world=mix(orbit,departurePoint,departureBlend);
  float endFade=1.0-smoothstep(1.0-uEndTaper,1.0,forward)*departure*departureAmount;
  float sidePosition=side*world.x;
  float contain=uC-uR*uSideContainment3D;
  float contained=contain+log(1.0+exp(clamp((sidePosition-contain)/0.16,-8.0,8.0)))*0.16;
  world.x=side*mix(sidePosition,contained,departureBlend);
  float depth01=clamp(0.5+world.z/1.0,0.0,1.0);
  float width=mix(uFarWidthScale3D,uNearWidthScale3D,depth01)*(1.0+0.12*depthBuild);
  float brightness=mix(uFarBrightnessScale3D,uNearBrightnessScale3D,depth01);
  vec3 tangent2=normalize(pNext-pPrev);
  vec3 widthDirection=normalize(vec3(-tangent2.y,tangent2.x,0.0));
  float stripWidth=mix(uInitialStripWidth3D,uEnergeticStripWidth3D,brightnessEnergy);
  float glowWidth=mix(uInitialGlowScale3D,uEnergeticGlowScale3D,brightnessEnergy);
  world+=widthDirection*aSide*stripWidth*width*mix(1.0,glowWidth,uGlow);
  float aspect=uResolution.x/uResolution.y;
  float perspective=1.0/max(1.0-world.z*uPerspectiveStrength3D,0.62);
  vec2 projected=world.xy*perspective/vec2(aspect,1.0);
  gl_Position=vec4(projected,-world.z*perspective/3.5,1.0);
  vActive=activation;
  vDepth01=depth01;
  vBrightness=brightness;
  vBrightnessEnergy=brightnessEnergy;
  vCoreEmission=mix(uInitialCoreEmission3D,uPeakCoreEmission3D,brightnessEnergy);
  vHaloEmission=mix(uInitialHaloEmission3D,uPeakHaloEmission3D,brightnessEnergy);
  vAlpha=activation*preFade*endFade;
  vGlow=uGlow;
}
