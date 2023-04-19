Shader "VFX/Warp_Drive"
{
    Properties
    {
        [Header(SETTINGS)]
        [Space(10)]
        _Color ("Color", Color) = (1, 1, 1, 1)
        _Fade ("Fade", Range(1, 2)) = 1 //Desvanecimiento en los extremos
        _WarpSize ("Size", Range(0.0, 0.5)) = 0.1
        _WarpDepth ("Depth", Range(0, 2)) = 0.3
        _WarpSpeed ("Speed", Range(-5, 5)) = 1
        _WarpTileX ("Tile X", Range(1, 10)) = 10
        _WarpTileY ("Tile Y", Range(1, 10)) = 10
    }
    SubShader
    {
        Tags
        {
            "Queue"="Transparent"
            "RenderType"="Transparent"
        }
        Blend One One
        ZWrite Off
        Cull Off
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float2 uvMask : TEXCOORD1; //Se usa para el Fade
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float2 uvMask : TEXCOORD1;
            };

            float4 _Color;
            float _Fade;
            float _WarpSize;
            float _WarpDepth;
            float _WarpSpeed;
            float _WarpTileX;
            float _WarpTileY;

            //Funcion para crear la textura del Warp Drive
            float WarpTex(float2 uv)
            {
                float left_wall = step(uv.x, _WarpSize); //Crea una pared de 0.1 del lado izquierdo
                float right_wall = step(1 - uv.x, _WarpSize);
                left_wall += right_wall;

                float top_grad = smoothstep(uv.y, uv.y - _WarpDepth, 0.5); //Degradado en Y, con lerp de 0.5
                float bottom_grad = smoothstep(1 - uv.y, 1 - uv.y - _WarpDepth, 0.5);
                float cut = clamp(top_grad + bottom_grad, 0, 1); //Clampea la suma de los gradientes top y bottom entre 0 y 1

                return clamp((1 - left_wall) * (1 - cut), 0, 1);
            }

            //Funcion para crear un valor aleatorio, la funcion es del nodo Simple Noise en Shader Graph
            float unity_noise_randomValue(float2 uv)
            {
                return frac(sin(dot(uv, float2(12.9898, 78.233))) * 43578.5453);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv; //Es igual al input de UVs cuando en el shader no se usan texturas
                o.uvMask = v.uvMask;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                i.uv.x *= _WarpTileX; //Crea repeticiones en las UVs
                i.uv.y *= _WarpTileY;
                i.uv.y += (_Time.y * _WarpSpeed); //Agrega movimiento en Y

                float2 uvFrac = float2(frac(i.uv.x), frac(i.uv.y)); //Guarda la fraccion de las coordenadas UV
                float2 id = floor(i.uv); //Guarda el valor de las UVs sin decimales, sirve para diferenciar una textura de otra en las coordenadas UV

                float x = 0; //Se usa para el offset en X
                float y = 0;
                fixed4 col = 0;

                //Bucles for anidados para el offset en X y Y
                for(y = -1; y <= 1; y++)
                {
                    for(x = -1; x <= 1; x++)
                    {
                        float2 offset = float2(x, y);
                        float noise = unity_noise_randomValue(id + offset);
                        float size = frac(noise * 123.32);
                        float warp = WarpTex(uvFrac - offset - float2(noise, frac(noise * 56.21)));
                        col += warp * size;
                    }
                }

                float vortexFade = abs(i.uvMask.y - 0.5) * _Fade; //Mascara del Fade, 0.5 es para que quede centrado

                return clamp(col - vortexFade, 0, 1) * _Color;
            }
            ENDCG
        }
    }
}