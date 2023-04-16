Shader "VFX/Super_Star"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [KeywordEnum(Off, On)] _IsActive("Is Active", float) = 0
        _Speed ("Color Speed", Range(5, 10)) = 10
        _ColorPower ("Color Power", Range(0, 1)) = 0.5
        _FresnelPower ("Fresnel Power", Range(1, 2)) = 1
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
            #pragma multi_compile _ISACTIVE_OFF _ISACTIVE_ON

            #include "UnityCG.cginc"
            #include "Assets/CGFiles/LocalFunctionsCG.cginc"
            

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 vertex : SV_POSITION;
                float2 uv : TEXCOORD0;
                float3 normal : NORMAL;
                float3 position_world : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Speed;
            float _ColorPower;
            float _FresnelPower;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz; //Transforma las normales a world space y las normaliza
                o.position_world = mul(unity_ObjectToWorld, v.vertex).xyz; //Transforma los vertices a world space
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float speed = ceil(_Time.y * _Speed); //ceil() hace que el color cambie en una frecuencia especifica, o sea que los colores no pasen de uno a otro de forma suavisada, si no parpadeando de uno a otro
                float3 star_color = (float3(1, 1, 1) + speed) + float3(0, 2, 4); //float3(0, 2, 4) permite alternar entre los colores y que no salga el color negro entre ellos
                star_color = cos(star_color) * _ColorPower;

                float3 normal_world = i.normal;
                float3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.position_world).xyz;

                float fresnel = 0;
                Unity_FresnelEffect_float(normal_world, view_dir, _FresnelPower, fresnel);

                fixed4 col = tex2D(_MainTex, i.uv);

                #if _ISACTIVE_ON
                    return col + float4(star_color, 1) + fresnel;
                #else
                    return col;
                #endif
            }
            ENDCG
        }
    }
}