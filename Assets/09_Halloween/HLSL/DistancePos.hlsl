void DistancePos_half
(
    in float3 playerPos,
    in float3 worldPos,
    in float radius,
    in float3 primaryTex,
    in float3 secondaryTex,
    out float3 Out
)
{
    if(distance(playerPos.xyz, worldPos.xyz) > radius)
    {
        Out = primaryTex;
    }
    else if(distance(playerPos.xyz, worldPos.xyz) > radius - 0.2)
    {
        Out = float4(1, 1, 1, 1);
    }
    else
    {
        Out = secondaryTex;
    }
}