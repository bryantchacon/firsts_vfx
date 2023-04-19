void Anisotropic_float
(
    float AnisoU,
    float AnisoV,
    float3 TangentDir,
    float3 NormalDir,
    float3 LightDir,
    float3 ViewDir,
    float AnisoFactor,
    out float3 Out
)
{
    float pi = 3.141592;
    float3 halfwayVector = normalize(LightDir + ViewDir);
    float3 NdotH = dot(NormalDir, halfwayVector);
    float3 HdotT = dot(halfwayVector, TangentDir);
    float3 HdotB = dot(halfwayVector, cross(TangentDir, NormalDir));
    float3 VdotH = dot(ViewDir, halfwayVector);
    float3 NdotL = dot(NormalDir, LightDir);
    float3 NdotV = dot(NormalDir, ViewDir);

    float power = AnisoU * pow(HdotT, 2) + AnisoV * pow(HdotB, 2);
    power /= 1.0 - pow(NdotH, 2);

    float spec = sqrt((AnisoU + 1) * (AnisoV + 1)) * pow(NdotH, power);
    spec /= 8.0 * pi * VdotH * max(NdotL, NdotV);

    Out = clamp(spec * AnisoFactor, 0, 1);
}