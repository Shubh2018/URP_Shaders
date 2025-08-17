Shader "Unlit/Trig"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Speed ("Rotation Speed", Range(0, 3)) = 1
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

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

            float _Speed;

            float rotation(float4 vertex)
            {
                float c = cos(_Time.y * _Speed);
                float s = sin(_Time.y * _Speed);
                
                float4x4 m = float4x4
                (
                     c, 0, s, 0,
                     0, 1, 0, 0,
                    -s, 0, c, 0,
                     0, 0, 0, 1
                );

                return mul(m, vertex);
            }

            v2f vert (appdata v)
            {
                v2f o;
                float3 rotVertex = float3(v.vertex.x * abs(sin(_Time.y * _Speed)), v.vertex.y, v.vertex.z* abs(cos(_Time.y * _Speed)));
                o.vertex = TransformObjectToHClip(rotVertex.xyz);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
