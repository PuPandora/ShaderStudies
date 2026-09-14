Shader "ShaderStudies/ToonHLSL"
{
    Properties
    {
        [HDR]_LitColor("Lit Color", Color) = (1, 1, 1, 1)
        _ShadowColor("Shadow Color", Color) = (0, 0, 0, 1)
        _ShadowThreshold("Shadow Threshold", Range(0.0, 1.0)) = 0.3
        _Smoothness("Smoothness", Range(0.001, 1)) = 0.001
        [Toggle(_RIMLIGHT_ON)]_RimLightOn("Rim Light On", float) = 1 
        [HDR]_RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimPower("Rim Power", Range(1, 8)) = 8
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Opaque"
            "Queue" = "Geometry"
        }

        Pass
        {
            Name "Unlit"
            Tags { "LightMode" = "UniversalForward" }

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma shader_feature_local _RIMLIGHT_ON

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Lighting.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
                float3 normalOS   : NORMAL;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float3 normalWS   : TEXCOORD0;
                float3 positionWS : TEXCOORD1;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _LitColor;
                float4 _ShadowColor;
                float _ShadowThreshold;
                float _Smoothness;
                float4 _RimColor;
                float _RimPower;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.normalWS   = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float3 N = normalize(IN.normalWS);
                float3 V = GetWorldSpaceNormalizeViewDir(IN.positionWS);
                Light L = GetMainLight();
                
                // 툰
                float NdotL = dot(N, L.direction);
                float smoothHalf = _Smoothness * 0.5;
                float toonStep = smoothstep(_ShadowThreshold - smoothHalf,
                                            _ShadowThreshold + smoothHalf,
                                            NdotL);
                float4 toon = lerp(_ShadowColor, _LitColor, toonStep);
                float4 color = toon;
                
                #ifdef _RIMLIGHT_ON
                // 림 라이트
                float NdotV = dot(N, V);
                float4 rimLight = pow(1 - saturate(NdotV), _RimPower) * _RimColor;
                color = color + rimLight * toonStep;
                #endif
                
                return color;
            }
            ENDHLSL
        }
    }
}