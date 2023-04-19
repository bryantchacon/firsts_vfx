//Este script permite renderizar las sombras sobre la superficie de los objetos
//Para que las sombras funcionen deben estar activadas en Directional Light > Light > Shadows > Shadow Type > Soft/Hard Shadows y en el URP Asset > Lighting activar la opcion Cast Shadows

#ifndef MAINLIGHT_INCLUDED
#define MAINLIGHT_INCLUDED

void Main_Light_Pro_float
(
    float3 WorldPos,
    out half3 Direction,
    out half3 Color,
    out half DistanceAtten,
    out half ShadowAtten
)
{
#ifdef SHADERGRAPH_PREVIEW
    Direction = half3(0, 1, 0);
    Color = 1;
    DistanceAtten = 1;
    ShadowAtten = 1;
#else
    #if SHADOWS_SCREEN
        half4 clipPos = TransformWorldToHClip(WorldPos);
        half4 shadowCoord = ComputeScreenPos(clipPos);
    #else
        half4 shadowCoord = TransformWorldToShadowCoord(WorldPos);
    #endif

    #if defined(UNIVERSAL_LIGHTING_INCLUDED)
        Light mainLight = GetMainLight(shadowCoord);
        Direction = mainLight.direction;
        Color = mainLight.color;
        DistanceAtten = mainLight.distanceAttenuation;
        ShadowAtten = mainLight.shadowAttenuation;
    #endif
#endif
}

#endif