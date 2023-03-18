Shader "VFX/EyeColor"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FirstGradCol ("First Gradient Color", Color) = (1, 1, 1, 1)
        _SecondGradCol ("Second Gradient Color", Color) = (1, 1, 1, 1)
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Opaque"
            "Queue"="Transparent+1"
        }
        ZWrite Off //Desactiva el zbuffer
        ZTest Greater //Renderiza el objeto solo cuando esta detras de otros, se complementa con "Queue"="Transparent+1"
        Blend SrcAlpha OneMinusSrcAlpha //Blend normal
        Cull Off //Esta en off para que el EyeColor izquierdo se pueda renderizar al voltear la geometria ya que su valor original es Back
        LOD 100

        Pass
        {
            Name "Color Pass"

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float4 color : COLOR;
            };

            float4 _FirstGradCol;
            float4 _SecondGradCol;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;

                //NOTA: Al asignar dos colores como lerp a las UVs estos automaticamente se muestran como un degradado de uno a otro porque asi son las UVs y no de forma lineal como en las texturas, asi que no hay necesidad de aplicar smoothstep()
                o.color = lerp(_FirstGradCol, _SecondGradCol, o.uv.y); //Optimizacion de hacer que el calculo del color sea aqui en el vertex shader en lugar de en el fragment shader
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }

        Pass
        {
            Name "Rays Pass"
            
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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDCG
        }
    }
}