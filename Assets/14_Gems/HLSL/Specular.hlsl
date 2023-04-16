half3 unity_lighting
(
    half3 lightColor,
    half3 lightDir,
    half3 normal,
    half3 viewDir,
    half3 specular,
    half smoothness
)
{
    float3 halfVec = SafeNormalize(float3(lightDir) + float3(viewDir));
    half NdotH = saturate(dot(normal, halfVec));
    half modifier = pow(NdotH, smoothness);
    half3 specularReflection = specular * modifier;

    return lightColor * specularReflection;
}

void Specular_float
(
    half3 Specular,
    half Smoothness,
    half3 LightDir,
    half3 Color,
    half3 WorldNormal,
    half3 WorldView,
    out half3 Render
)
{
    #ifdef SHADERGRAPH_PREVIEW
        Specular = half3(1, 1, 1);
        Render = 0;
    #else
        Smoothness = exp2(10 * Smoothness + 1);
        WorldNormal = normalize(WorldNormal);
        WorldView = SafeNormalize(WorldView);

        Render = unity_lighting(Color, LightDir, WorldNormal, WorldView, Specular, Smoothness);
    #endif
}