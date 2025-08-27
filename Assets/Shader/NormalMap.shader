Shader "Unlit/NormalMap"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap ("NormalMap", 2D) = "white" {}
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
                float4 tangent : TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float2 uv_normal : TEXCOORD1;
                float3 normal_world : TEXCOORD2;
                float4 tangent_world : TEXCOORD3;
                float3 binormal_world : TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            sampler2D _NormalMap;
            float4 _NormalMap_ST;

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                //adding tiling and offset to normalmap
                o.uv_normal = TRANSFORM_TEX(v.normal, _NormalMap);

                //transform normals to world-space
                o.normal_world = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0)));

                //transform tangent to world space
                o.tangent_world = normalize((mul(v.tangent, unity_WorldToObject)));

                //calculate cross product between normal and tangent
                o.binormal_world = normalize(cross(o.normal_world, o.tangent_world) * v.tangent.w);
                return o;
            }

            half4 frag (v2f i) : SV_Target
            {
                half4 col = tex2D(_MainTex, i.uv);
                half4 normal_map = tex2D(_NormalMap, i.uv_normal);
                half3 normal_compressed = UnpackNormal(normal_map);
                float3x3 TBN_Matrix = float3x3
                (
                    i.tangent_world.xyz,
                    i.binormal_world,
                    i.normal_world
                );

                half3 normal_color = normalize(mul(normal_compressed, TBN_Matrix));
                
                return half4(normal_color, 1);
            }
            ENDHLSL
        }
    }
}
