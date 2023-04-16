//Genera la primitiva de la textura
float4 unity_triangle(float2 uv, float Size, float Sides)
{
    float distance = 0;
    float4 render = 0;
    float2 st = 0;
    int vertex = Sides;

    st = uv;
    st *= 2 - 1;
    float angle = atan2(st.x, st.y) + 3.14159265359;
    float radius = 6.28318530718 / float(vertex);
    distance = cos(floor(0.5 + angle / radius) * radius - angle) * length(st);

    render = (1.0 - smoothstep(Size, Size + 0.01, distance));
    return render;
}

//Genera un valor aleatorio
float unity_noise_randomValue(float2 uv)
{
    return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43758.5453);
}

void Dynamic_Texture_float(float3 WorldPos, float2 UV_render, float Sides, out float4 Out)
{
    UV_render *= 32;
    UV_render += _WorldSpaceCameraPos.xy;

    float2 uvFrac = float2(frac(UV_render.x), frac(UV_render.y));
    float2 id = floor(UV_render);
    float4 col = 0;
    float x = 0;
    float y = 0;

    for(y = -1; y <= 1; y++)
    {
        for(x = -1; x <= 1; x++)
        {
            float2 offset = float2(x, y);
            float noise = unity_noise_randomValue(id + offset);
            float size = frac(noise * 123.32);
            float render = unity_triangle(uvFrac - offset - float2(noise, frac(noise * 23.12)), size * 1.5, Sides);

            render *= (sin(noise * ((_WorldSpaceCameraPos.x - (WorldPos.x * 5) + noise) * 20)));
            render *= (cos(noise * ((_WorldSpaceCameraPos.y - (WorldPos.y * 5) + noise) * 20)));
            render *= (sin(noise * ((_WorldSpaceCameraPos.z - (WorldPos.z * 5) + noise) * 20)));

            col += render;
        }
    }

    Out = col;
}