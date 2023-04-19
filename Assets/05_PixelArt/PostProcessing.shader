//EL MATERIAL DONDE VA ESTE SHADER SE PASA COMO PARAMETRO EN EL PostProcessingScript()

Shader "VFX/PostProcessing"
{
    Properties
    {
        [HideInInspector] _MainTex("Texture", 2D) = "white" {}
        _Saturate("Saturate", Range(1, 2)) = 1
        _Contrast("Contrast", Range(1, 0)) = 1

        [HideInInspector] _RatioX("Ratio X", float) = 1 //Tamaño de un pixel en x
        [HideInInspector] _RatioY("Ratio Y", float) = 1 //Tamaño de un pixel en y
        [HideInInspector] _PixelSize("Pixel Size", float) = 1 //Escala de un pixel
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
        }
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
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Saturate;
            float _Contrast;
            float _RatioX;
            float _RatioY;
            float _PixelSize;

            v2f vert(appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float2 pixelArt(float2 uv, float pixelSample)
            {
                pixelSample *= _PixelSize;
                half bitX = _RatioX / pixelSample;
                half bitY = _RatioY / pixelSample;

                half2 pixeledUV = half2((int)(uv.x / bitX) * bitX, (int)(uv.y / bitY) * bitY);
                return pixeledUV;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, pixelArt(i.uv, 300)) * _Saturate;
                fixed4 contrast = col * col;

                fixed4 render = lerp(contrast, col, _Contrast);
                return render;
            }
            ENDCG
        }
    }
}