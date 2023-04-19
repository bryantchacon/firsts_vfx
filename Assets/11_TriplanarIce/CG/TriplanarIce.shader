Shader "Custom/TriplanarIce"
{
    Properties
    {
        _Color ("Color", Color) = (1,1,1,1)
        _MainTex ("Albedo (RGB)", 2D) = "white" {}
        _SecondaryTex ("SecondaryTex", 2D) = "white" {}
        _Glossiness ("Smoothness", Range(0,1)) = 0.5
        _Metallic ("Metallic", Range(0,1)) = 0.0
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 200

        CGPROGRAM
        // Physically based Standard lighting model, and enable shadows on all light types
        #pragma surface surf Standard fullforwardshadows

        #include "Assets/CGFiles/LocalFunctionsCG.cginc"

        // Use shader model 3.0 target, to get nicer looking lighting
        #pragma target 3.0

        sampler2D _MainTex;
        sampler2D _SecondaryTex;

        struct Input
        {
            float2 uv_MainTex;
            float3 worldNormal;
            float3 worldPos;
        };

        half _Glossiness;
        half _Metallic;
        fixed4 _Color;

        // Add instancing support for this shader. You need to check 'Enable Instancing' on materials that use the shader.
        // See https://docs.unity3d.com/Manual/GPUInstancing.html for more information about instancing.
        // #pragma instancing_options assumeuniformscaling
        UNITY_INSTANCING_BUFFER_START(Props)
            // put more per-instance properties here
        UNITY_INSTANCING_BUFFER_END(Props)

        void surf (Input IN, inout SurfaceOutputStandard o)
        {
            float2 yz_proj = 0;
            Unity_Rotate_Degrees_float(IN.worldPos.yz, 0.5, 270, yz_proj);
            
            fixed4 tp = tex2D(_MainTex, IN.worldPos.xz); //Samplea la textura principal (de la nive), para que se proyecte de arriba hacia abajo
            fixed4 bt = tex2D(_SecondaryTex, IN.worldPos.xz);
            fixed4 lr = tex2D(_SecondaryTex, yz_proj); //Sampleo de la textura sencundaria a los lados, en este caso se pone yz_proj porque si no la textura sale volteada y se corrige usando la funcion Unity_Rotate_Degrees_float() que proviene de LocalFunctionsCG.cginc
            fixed4 fb = tex2D(_SecondaryTex, IN.worldPos.xy);

            fixed4 up_col = max(0, smoothstep(IN.worldNormal.y, IN.worldNormal.y - 0.1, 0.5)) * tp; //Setea la textura principal en la parte de arriba del objeto, max() es para evitar errores graficos haciendo que no devuelva numeros negativos, smoothstep() es para evitar que los bordes de la textura se difuminen
            fixed4 lo_col = max(0, smoothstep(-IN.worldNormal.y, -IN.worldNormal.y - 0.8, 0.5)) * bt; //IN es negativo porque la textura secundaria se proyectara en la parte de abajo del objeto
            fixed4 si_col = IN.worldNormal.x * lr; //Setea la textura secundaria a los lados
            fixed4 fr_col = IN.worldNormal.z * fb;

            // Albedo comes from a texture tinted by color
            fixed4 c = (up_col + lo_col + abs(si_col) + abs(fr_col)) * _Color; //Asigna las texturas principal y secundaria al objeto, se usa abs() con si_col para que la textura secundaria se proyecte en ambos lados
            o.Albedo = c.rgb;
            // Metallic and smoothness come from slider variables
            o.Metallic = _Metallic;
            o.Smoothness = _Glossiness;
            o.Alpha = c.a;
        }
        ENDCG
    }
    FallBack "Diffuse"
}