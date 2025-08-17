Shader "Unlit/Length"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Radius ("Radius", Range(0.0, 0.5)) = 0.3
        _Center ("Center", Range(0, 1)) = 0.5
        _Smooth ("Smooth", Range(0, 0.5)) = 0.01
    }
    SubShader
    {
        Tags
        {
            "RenderType"="Transparent"
            "Queue"="Transparent"    
        }
        
        LOD 100
        Blend DstAlpha OneMinusDstAlpha

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _Radius;
            float _Center;
            float _Smooth;

            float circle(float2 p, float center, float radius, float smooth)
            {
                float2 vec = p - center;
                float c = length(vec); //- radius;
                return smoothstep(c - smooth, c + smooth, radius);
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            float4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                float cir = circle(i.uv, _Center, _Radius, _Smooth);
                return float4(cir, cir, cir, 1);
            }
            ENDHLSL
        }
    }
}
