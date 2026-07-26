#version 300 es
precision highp float;
in vec2 vUv;
out vec4 outColor;

uniform vec2 uResolution;
uniform float uTime, uProgress, uDuration, uDiamondCompleteTime, uDiamondHoldDuration, uSpectralEmergenceDuration, uSpectralExpansionDuration, uEcstaticHoldDuration;
uniform float uMorphStart, uMorphEnd, uCouplingStart, uRotationBuildStart, uRotationBuildEnd, uC, uR, uA, uEpsilon;
uniform float uFilaments, uInitialLines, uPeakLines, uRevealSoftness;
uniform float uStartSpread, uEndSpread, uOmega0, uOmega1, uSpeedRatio, uCounterRotation;
uniform float uBaseImperfection, uPeakImperfection, uDifferentialRotation;
uniform float uLargeBulgeStrength, uPinchStrength, uSpacingIrregularity, uBrightnessLandmarkStrength, uInitialHaloWidth;
uniform float uTravellingEnergyFrequency, uTravellingEnergySpeed, uRadialBreathing;
uniform float uPreConvergenceEnergy, uConvergenceImpulse, uSettlingStrength, uFinalResidualMotion;
uniform float uDepth, uParallax, uCoreWidth, uHaloWidth, uExposure, uBackground, uSeed;
uniform float uSpectralSamples, uSpectralExpansionSpeed, uSpectralExpansionAcceleration, uPrimaryBandFrequency, uSecondaryBandAmount, uBandSoftness, uBandWidth;
uniform float uXExpansionScale, uYExpansionScale, uZExpansionScale, uDepthStretch, uVolumetricDensity, uSpectralSaturation, uSpectralVibrance, uSpectralExposure, uSpectralEmissionIntensity, uInitialSpectralBrightness, uChromaticAmbientStrength, uNeutralAmbientStrength, uDepthChromaPreservation, uDominantLayerColourPreservation, uBandCentreChromaticHighlight, uInternalRidgeIntensity, uDistantChromaticFill, uChromaticBloomStrength, uDepthAbsorption, uOverlapWhiteningThreshold, uOverlapWhiteningSoftness, uOverlapWhiteningStrength, uVioletLuminanceBoost, uBlueLuminanceBoost, uRedLuminanceBoost, uHighlightColourPreservation, uCentralWhiteStrength, uOverlapWhitening, uWaveDeformation, uEcstaticPulseStrength, uCameraDrift, uResidualDiamondVisibility, uReducedIntensity;
uniform float uRibbonCount, uRibbonSegments, uDiamondSpectralFadeDuration, uRibbonSourceWidth, uRibbonOuterWidth, uRibbonWidthGrowth, uRibbonLength, uRibbonGrowthDuration, uRibbonDelaySpread;
uniform float uXDirectionSpread, uYDirectionSpread, uZDirectionSpread, uForwardRibbonProportion, uBackwardRibbonProportion, uRibbonCurvature, uSecondaryBend, uRibbonTwist, uRibbonTwistSpeed, uRibbonTranslucency, uRibbonEmission, uRibbonCentreHighlight, uRibbonEdgeHighlight, uRibbonOverlapBrightness, uRibbonDepthSoftness, uNearCameraFade, uRibbonColourVariation, uSpectrumAcrossWidth, uSpectrumAlongLength, uRibbonMotionSpeed, uResidualCentralGlow;

const float PI=3.14159265359;
float hash(float n){return fract(sin(n*91.17)*43758.5453);}
float smoother(float x){return x*x*x*(x*(x*6.0-15.0)+10.0);}
float gauss(float x,float w){return exp(-pow(x/max(w,0.00001),2.0));}
float ramp(float a,float b,float x){return smoother(clamp((x-a)/(b-a),0.0,1.0));}
vec3 hsvToRgb(vec3 c){
  vec3 k=vec3(1.0,2.0/3.0,1.0/3.0);
  vec3 p=abs(fract(c.xxx+k)*6.0-3.0);
  return c.z*mix(k.xxx,clamp(p-1.0,0.0,1.0),c.y);
}
vec3 wavelengthToLinearRGB(float wavelength){
  float t=clamp((wavelength-390.0)/310.0,0.0,1.0);
  float hue=fract(0.76-0.76*t);
  vec3 rgb=hsvToRgb(vec3(hue,0.86,1.0));
  float edge=0.72+0.28*smoothstep(390.0,420.0,t)*(1.0-smoothstep(0.88,1.0,t));
  return pow(max(rgb*edge,vec3(0.0)),vec3(1.35));
}

void main(){
  vec2 p=(2.0*gl_FragCoord.xy-uResolution)/uResolution.y;
  float animationTime=clamp(uProgress,0.0,1.0)*uDuration;
  float diamondSettleEndTime=uDiamondCompleteTime;
  float diamondSettleStartTime=max(0.0,diamondSettleEndTime-1.5);
  float diamondHoldStartTime=diamondSettleEndTime;
  float spectralStartTime=diamondHoldStartTime+uDiamondHoldDuration;
  float diamondRenderTime=min(animationTime,diamondHoldStartTime);
  float diamondMotion=1.0-smoother(clamp((animationTime-diamondSettleStartTime)/max(diamondHoldStartTime-diamondSettleStartTime,0.001),0.0,1.0));
  float spectralStart=spectralStartTime;
  float elapsed=animationTime;
  float spectralGate=step(spectralStartTime,animationTime);
  float spectralTotal=max(0.1,uSpectralEmergenceDuration+uSpectralExpansionDuration+uEcstaticHoldDuration);
  float spectralProgress=clamp((elapsed-spectralStart)/spectralTotal,0.0,1.0);
  float spectralTime=max(0.0,animationTime-spectralStartTime);
  float emergence=smoother(clamp(spectralTime/max(uSpectralEmergenceDuration,0.25),0.0,1.0));
  float expansionRaw=smoother(clamp((spectralTime-0.10)/max(uSpectralExpansionDuration,0.75),0.0,1.0));
  float expansion=1.0-pow(1.0-expansionRaw,2.5);
  float saturationArrival=smoother(clamp(spectralTime/0.55,0.0,1.0));
  float geometryArrival=smoother(clamp(spectralTime/1.5,0.0,1.0));
  float fullField=smoother(clamp((spectralTime-0.25)/1.75,0.0,1.0));
  float s=clamp(elapsed/max(uDiamondCompleteTime,0.01),0.0,1.0);
  float build=ramp(0.08,0.66,s);
  float energyRise=ramp(0.10,0.68,s);
  float energyFall=ramp(0.76,0.96,s);
  float activeEnergy=energyRise*(1.0-0.75*energyFall);
  float settle=ramp(0.84,1.0,s);
  float coupling=ramp(uCouplingStart,0.85,s);
  float morph=ramp(uMorphStart,uMorphEnd,s);
  float collapse=ramp(0.72,0.94,s);
  float impulse=sin(PI*morph)*sin(PI*morph)*uConvergenceImpulse;
  float rotationBuild=ramp(uRotationBuildStart,uRotationBuildEnd,s);
  float omega=uOmega0+(uOmega1-uOmega0)*pow(rotationBuild,2.2);
  float phase=diamondRenderTime*omega*6.2831853;
  float settleAmount=clamp(settle*uSettlingStrength,0.0,1.0);
  float rotationVisibility=mix(1.0,max(uFinalResidualMotion,0.02),settleAmount);
  float depthEnvelope=ramp(0.18,0.68,s)*(1.0-0.42*settle);
  float depthAmount=uDepth*depthEnvelope;
  vec2 cameraDrift=vec2(sin(diamondRenderTime*0.13),cos(diamondRenderTime*0.11))*0.012*depthEnvelope*diamondMotion;
  p-=cameraDrift;
  float convergenceGate=smoother(clamp((s-0.38)/0.24,0.0,1.0));
  vec3 legacyLinear=vec3(0.0035,0.0028,0.0020)*uBackground;

  for(int i=0;i<96;i++){
    float fi=float(i); if(fi>=uFilaments) break;
    float n=(fi+0.5)/max(uFilaments,1.0);
    float side=mod(fi,2.0)*2.0-1.0;
    float rnd=hash(fi+uSeed), rnd2=hash(fi*2.71+3.2), z=n*2.0-1.0;
    float initialFraction=clamp(2.0*uInitialLines/max(uFilaments,1.0),0.03,1.0);
    float peakFraction=clamp(2.0*uPeakLines/max(uFilaments,1.0),initialFraction,1.0);
    float activeFraction=mix(initialFraction,peakFraction,0.5+0.5*build);
    float activationThreshold=hash(fi*1.73+uSeed*0.37);
    float filamentActivation=smoothstep(activationThreshold-uRevealSoftness,activationThreshold+uRevealSoftness,activeFraction);
    if(filamentActivation<0.001) continue;

    float direction=side<0.0?1.0:mix(1.0,-1.0,uCounterRotation);
    float systemRate=side<0.0?1.0:uSpeedRatio;
    float differential=1.0+uDifferentialRotation*(z+0.45*(rnd-0.5));
    float systemPhase=phase*systemRate*direction*differential*rotationVisibility;
    float synchronizedPhase=mix(systemPhase,phase*1.02, coupling);
    float depthScale=1.0/(1.0+z*depthAmount*0.35);
    vec2 q=p/depthScale+z*uParallax*vec2(sin(synchronizedPhase*0.14+fi),cos(synchronizedPhase*0.12+fi*1.7))*depthEnvelope*diamondMotion;
    float theta=atan(q.y,q.x-side*uC);
    float seed1=rnd*6.2831, seed2=rnd2*5.71;
    float warp=(uBaseImperfection+uPeakImperfection*activeEnergy)*(1.0-0.96*settle)*diamondMotion;
    float harmonic=0.42*sin(2.0*theta+synchronizedPhase+seed1)
      +0.27*sin(3.0*theta-1.37*synchronizedPhase+seed2)
      +0.19*sin(5.0*theta+0.61*synchronizedPhase+seed1*1.7)
      +0.12*sin(8.0*theta-0.23*synchronizedPhase+seed2*1.3);
    float travelling=0.5+0.5*sin(uTravellingEnergyFrequency*theta-uTravellingEnergySpeed*synchronizedPhase+seed1);
    float landmark=0.5+0.5*sin((2.0+1.5*rnd)*theta-(0.65+0.4*seed2)*synchronizedPhase+seed1*1.4);
    float bunching=1.0+uSpacingIrregularity*activeEnergy*(travelling-0.5)+0.08*sin(theta*2.0-synchronizedPhase*0.6+seed2);
    float breathing=uRadialBreathing*activeEnergy*sin(synchronizedPhase*0.38+theta*2.0+seed2)*diamondMotion;
    float expandedSpread=uStartSpread*(1.0+0.45*activeEnergy);
    float currentSpread=mix(expandedSpread,uEndSpread,pow(collapse,1.8));
    float offset=((n-0.5)*currentSpread*bunching+breathing)*(1.0-0.35*morph);
    float radialLandmark=uLargeBulgeStrength*warp*(0.7+0.5*rnd)*harmonic;
    radialLandmark+=uPinchStrength*warp*0.45*sin(3.0*theta-synchronizedPhase*1.2+seed2);
    float ay=abs(q.y), rr=uR+offset+uR*radialLandmark;
    float root=sqrt(max(rr*rr-ay*ay,0.00001));
    float xCircle=uC-root+offset*0.24;
    float peakE=max(0.018,uEpsilon+offset*0.22);
    float xPeak=peakE*max(uA-ay,0.0)/(ay+peakE);
    float xCurve=mix(xCircle,xPeak,morph);
    float dCircle=ay/root;
    float dPeak=-peakE*(uA+peakE)/((ay+peakE)*(ay+peakE));
    float derivative=mix(dCircle,dPeak,morph);
    float quadrupole=(q.x*q.x-q.y*q.y)+0.45*(2.0*q.x*q.y);
    float bend=(coupling*0.018*quadrupole*side*(0.4+0.6*rnd)
      +impulse*0.07*quadrupole*side*(0.6+0.4*travelling))*diamondMotion;
    float inwardLean=coupling*0.018*sin(theta*2.0+synchronizedPhase)*side*diamondMotion;
    float lineX=side*xCurve+bend+inwardLean+offset*0.12*sin(synchronizedPhase+q.y*3.0);
    float d=abs(q.x-lineX)/sqrt(1.0+derivative*derivative);
    float aa=max(fwidth(d),0.00035);
    float localWidth=1.0+0.25*(travelling-0.5)*activeEnergy;
    float core=gauss(d,uCoreWidth*localWidth*(0.72+0.28/(1.0+depthAmount*0.35))+aa);
    float halo=gauss(d,mix(uInitialHaloWidth,uHaloWidth,morph)*localWidth*(0.75+0.25/(1.0+depthAmount*0.35))+aa*2.0);
    float reciprocalDomain=mix(1.0,1.0-smoothstep(uA-0.035,uA+0.035,ay),morph);
    float edgeFade=(smoothstep(1.15,0.96,ay)+smoothstep(0.02,0.16,ay)*0.16)*reciprocalDomain;
    float brightnessWave=0.72+uBrightnessLandmarkStrength*0.35*landmark+0.2*travelling;
    float intensity=(0.42+0.7*(1.0-n)*depthScale)*brightnessWave*edgeFade*filamentActivation;
    float energy=0.7+uPreConvergenceEnergy*activeEnergy+0.72*morph;
    vec3 bronze=mix(vec3(0.19,0.055,0.018),vec3(0.9,0.27,0.035),0.25+0.48*activeEnergy+0.18*morph);
    vec3 gold=mix(bronze,vec3(1.0,0.62,0.12),activeEnergy*0.8+morph*0.35);
    vec3 coreColor=mix(gold,vec3(1.0,0.96,0.68),smoothstep(0.7,1.0,morph));
    legacyLinear+=gold*halo*0.15*energy*intensity+coreColor*core*0.95*energy*intensity;
  }
  legacyLinear+=vec3(0.035,0.012,0.002)*activeEnergy*exp(-length(p)*1.6)*uPreConvergenceEnergy*convergenceGate;
  legacyLinear+=vec3(0.0012)*uNeutralAmbientStrength*convergenceGate;
  float diamondFade=smoother(clamp((spectralTime)/max(uDiamondSpectralFadeDuration,0.001),0.0,1.0));
  float diamondVisibility=1.0-diamondFade;
  vec3 linear=legacyLinear*diamondVisibility;

  vec3 spectralLinear=vec3(0.0);
  float reducedMix=mix(1.0,0.68,uReducedIntensity);
  float pulse=0.5+0.5*sin(spectralTime*0.42+sin(spectralTime*0.11)*0.7);
  float coverage=geometryArrival;
  vec2 spectralP=p+uCameraDrift*reducedMix*vec2(sin(spectralTime*0.12),cos(spectralTime*0.10));
  float expansionRadius=0.15+1.45*uSpectralExpansionSpeed*expansion+0.55*uSpectralExpansionAcceleration*expansion*expansion;
  float spectralVisibility=mix(0.72,1.0,saturationArrival)*spectralGate;
  float bandMotion=spectralTime*(0.22+0.32*reducedMix)+pulse*uEcstaticPulseStrength*0.18;
  float sampleCount=max(uSpectralSamples,1.0);
  float transmittance=1.0;
  for(int j=0;j<28;j++){
    float fj=float(j); if(fj>=sampleCount) break;
    float layer=(fj+0.5)/sampleCount;
    float z=(layer*2.0-1.0)*(0.9+3.2*coverage)*uDepthStretch;
    float depthScale=1.0+0.22*z*z;
    vec3 q=vec3(spectralP*depthScale,z*(0.42+0.92*coverage));
    float sharedWarp=uWaveDeformation*(0.22*sin(dot(q,vec3(1.1,-0.35,0.7))*1.7-bandMotion*0.35)+0.16*sin(dot(q,vec3(-0.4,1.2,0.55))*2.1+bandMotion*0.24));
    float phaseH=dot(q,vec3(1.05,0.12,0.4))*uPrimaryBandFrequency*0.72+sharedWarp-bandMotion*(0.72+0.12*z);
    float phaseV=dot(q,vec3(-0.08,1.18,0.52))*uPrimaryBandFrequency*0.68+sharedWarp*0.7-bandMotion*(0.61-0.08*z);
    float phaseD=dot(q,normalize(vec3(0.88,0.68,0.72)))*uPrimaryBandFrequency*0.64+sharedWarp*1.25-bandMotion*0.52;
    float phaseR=length(vec2(q.x*uXExpansionScale,q.y*uYExpansionScale))*uPrimaryBandFrequency*1.35+0.32*sin(q.z*3.0+bandMotion)-bandMotion*0.42;
    float waveH=0.5+0.5*sin(phaseH), waveV=0.5+0.5*sin(phaseV), waveD=0.5+0.5*sin(phaseD), waveR=0.5+0.5*sin(phaseR);
    float broadH=smoothstep(0.08,0.92,waveH), broadV=smoothstep(0.08,0.92,waveV), broadD=smoothstep(0.08,0.92,waveD), broadR=smoothstep(0.06,0.94,waveR);
    float familyStrength=(0.28+0.72*uBandWidth)*(0.22+0.28*broadH+0.25*broadV+0.25*broadD+0.22*broadR);
    float bandActivity=(broadH*uBandSoftness + broadV*(1.0-uBandSoftness)*0.9 + broadD*0.92 + broadR*0.86);
    bandActivity/=max(0.8+uBandSoftness,0.8);
    float centralGate=mix(exp(-length(q.xy)*3.3),1.0,coverage);
    float fill=mix(0.012*uDistantChromaticFill,0.06+0.12*(broadH+broadV+broadD+broadR)*0.25,uDistantChromaticFill*fullField);
    float density=(bandActivity*familyStrength+fill)*uVolumetricDensity*(0.008+0.022*coverage)*spectralVisibility*reducedMix*centralGate;
    float hueH=fract(0.52+0.115*phaseH/PI+layer*0.06+spectralTime*0.003);
    float hueV=fract(0.08+0.105*phaseV/PI-layer*0.05+spectralTime*0.002);
    float hueD=fract(0.34+0.10*phaseD/PI+z*0.08);
    vec3 colourH=wavelengthToLinearRGB(390.0+310.0*hueH);
    vec3 colourV=wavelengthToLinearRGB(390.0+310.0*hueV);
    vec3 colourD=wavelengthToLinearRGB(390.0+310.0*hueD);
    vec3 spectral=mix(colourH,colourV,0.18+0.10*broadV);
    spectral=mix(spectral,colourD,0.12+0.08*broadD);
    vec3 violetBlue=mix(vec3(0.22,0.01,1.0),vec3(0.01,0.25,1.0),0.5+0.5*sin(phaseH*0.11));
    vec3 cyanGreen=mix(vec3(0.0,0.75,1.0),vec3(0.01,0.95,0.16),0.5+0.5*sin(phaseV*0.09));
    vec3 yellowOrange=mix(vec3(1.0,0.9,0.02),vec3(1.0,0.18,0.01),0.5+0.5*sin(phaseD*0.12));
    vec3 redMagenta=mix(vec3(0.95,0.01,0.08),vec3(0.7,0.01,1.0),0.5+0.5*sin(phaseR*0.10));
    float familyWeight=max(broadH+broadV+broadD+broadR,0.001);
    vec3 vividFamily=(violetBlue*broadH+cyanGreen*broadV+yellowOrange*broadD+redMagenta*broadR)/familyWeight;
    spectral=mix(spectral,vividFamily,clamp(0.72*uDominantLayerColourPreservation,0.0,1.0));
    float hueT=clamp((390.0+310.0*fract(0.34+0.10*phaseD/PI+z*0.08)-390.0)/310.0,0.0,1.0);
    float violetWeight=1.0-smoothstep(0.08,0.22,hueT);
    float blueWeight=smoothstep(0.10,0.24,hueT)*(1.0-smoothstep(0.34,0.48,hueT));
    float redWeight=smoothstep(0.78,0.94,hueT);
    spectral*=1.0+violetWeight*uVioletLuminanceBoost+blueWeight*uBlueLuminanceBoost+redWeight*uRedLuminanceBoost;
    float luma=dot(spectral,vec3(0.2126,0.7152,0.0722));
    float effectiveSaturation=mix(uSpectralSaturation,uSpectralSaturation*0.72,uReducedIntensity)*(1.0+0.14*uDepthChromaPreservation*abs(z));
    spectral=mix(vec3(luma),spectral,effectiveSaturation);
    spectral=max(spectral,vec3(0.0));
    float whiteNear=exp(-length(q.xy)*3.8)*(1.0-saturationArrival)*uCentralWhiteStrength;
    spectral=mix(vec3(1.0,0.88,0.58),spectral,saturationArrival*uHighlightColourPreservation);
    float accumulatedLuminance=broadH+broadV+broadD+broadR;
    float whitening=smoothstep(uOverlapWhiteningThreshold,uOverlapWhiteningThreshold+uOverlapWhiteningSoftness,accumulatedLuminance)*uOverlapWhiteningStrength;
    spectral=mix(spectral,vec3(1.0),whiteNear*0.45+whitening);
    float surfaceLight=0.7+0.3*sin(phaseH*0.5+phaseD*0.32+z*1.7);
    float ridge=max(max(waveH,waveV),max(waveD,waveR));
    float bandHighlight=smoothstep(0.62,0.96,ridge)*uBandCentreChromaticHighlight*uChromaticBloomStrength;
    float alpha=clamp(density*(0.75+0.35*surfaceLight),0.0,0.08);
    float initialBrightness=mix(uInitialSpectralBrightness,1.0,geometryArrival);
    spectralLinear+=transmittance*spectral*alpha*uSpectralEmissionIntensity*initialBrightness*(1.0+0.42*surfaceLight+0.25*fullField+bandHighlight);
    spectralLinear+=transmittance*spectral*alpha*bandHighlight*uInternalRidgeIntensity;
    transmittance*=1.0-alpha*uDepthAbsorption;
    if(transmittance<0.035) break;
  }
  float finalH=0.5+0.5*sin(p.x*2.4+p.y*0.34-bandMotion*0.7+0.6*sin(p.y*1.3+bandMotion*0.2));
  float finalV=0.5+0.5*sin(p.y*2.1-p.x*0.28-bandMotion*0.56);
  float finalD=0.5+0.5*sin((p.x+p.y)*1.45+0.6*sin(p.x*1.1-bandMotion*0.15)-bandMotion*0.38);
  vec3 finalColour=wavelengthToLinearRGB(390.0+310.0*fract(0.02+finalH*0.96));
  finalColour=mix(finalColour,wavelengthToLinearRGB(390.0+310.0*fract(0.36+finalV*0.9)),0.34+0.18*finalD);
  finalColour=mix(finalColour,wavelengthToLinearRGB(390.0+310.0*fract(0.58+finalD*0.86)),0.22);
  spectralLinear+=finalColour*(0.06+0.32*fullField)*fullField*reducedMix*uSpectralEmissionIntensity*uDistantChromaticFill;
  float sourceGlow=exp(-length(spectralP)*7.0)*uResidualCentralGlow*emergence*(1.0-diamondFade);
  spectralLinear+=vec3(1.0,0.58,0.16)*sourceGlow*spectralGate;
  spectralLinear+=finalColour*uChromaticAmbientStrength*(0.024+0.055*fullField)*fullField*reducedMix;
  float aggregateLuma=dot(spectralLinear,vec3(0.2126,0.7152,0.0722));
  spectralLinear=max(spectralLinear,vec3(0.0));
  float aggregateChroma=max(max(spectralLinear.r,spectralLinear.g),spectralLinear.b)-min(min(spectralLinear.r,spectralLinear.g),spectralLinear.b);
  float adaptiveVibrance=uSpectralVibrance*(1.0-smoothstep(0.04,0.65,aggregateChroma));
  spectralLinear=mix(vec3(aggregateLuma),spectralLinear,mix(2.2+adaptiveVibrance,1.35+adaptiveVibrance*0.6,uReducedIntensity));
  spectralLinear=max(spectralLinear,vec3(0.0));
  if(animationTime<spectralStartTime) spectralLinear=vec3(0.0);
  spectralLinear*=spectralGate;
  linear+=spectralLinear*uSpectralExposure*mix(1.0,0.72,uReducedIntensity);
  vec3 mapped=linear*max(uExposure,0.01)/(1.0+linear*max(uExposure,0.01)*0.72);
  mapped=pow(max(mapped,0.0),vec3(0.92));
  outColor=vec4(mapped,1.0);
}
