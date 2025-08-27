Shader "Unlit/BasicLighting"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

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
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 normal : TEXCOORD1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            void unity_light(in float3 normals, out float3 Out)
            {
                
            }

            half3 normalWorld(half3 normal)
            {
                return normalize(mul(unity_ObjectToWorld, float4(normal, 0))).xyz;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = normalWorld(v.normal);
                return o;
            }

            float3 DXTCompression(float4 normalMap)
            {
                #if defined (UNITY_NO_DXT5nm)
                    return normalMap.rgb *2 - 1;
                #else
                    float3 normalCol = float3(normalMap.a * 2 - 1, normalMap.g * 2 - 1, 0);
                    normalCol.b = sqrt(1 - (pow(normalCol.r, 2)) + pow(normalCol.g, 2));

                    return normalCol;
                #endif
            }

            half4 frag (v2f i) : SV_Target
            {
                half3 normals = i.normal;
                half3 light = 0;

                unity_light(normals, light);
                return float4(light.xyz, 1);
                
                half4 col = tex2D(_MainTex, i.uv);
                return col;
            }
            ENDHLSL
        }
    }
}
