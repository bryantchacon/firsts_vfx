void IceSpecular_half
(
    half3 specular,
    half smoothness,
    half3 color,
    half3 worldNormal,
    half3 worldView,
    out half3 Out
)
{
#if SHADERGRAPH_PREVIEW
    Out = 1;
#else
    Light light = GetMainLight();
    smoothness = exp2(10 * smoothness + 1);
    worldNormal = normalize(worldNormal);
    worldView = SafeNormalize(worldView);
    Out = LightingSpecular(color, normalize(light.direction), worldNormal, worldView, half4(specular, 0), smoothness);
#endif
}