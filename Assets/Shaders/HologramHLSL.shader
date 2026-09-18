Shader "ShaderStudies/HologramHLSL"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (0.2, 0.2, 0.2, 1)
        _BaseAlpha("Base Alpha", Range(0, 1)) = 0.3
        [HDR]_RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimPower("Rim Power", Range(0.1, 8)) = 3
        [HDR]_LineColor("Line Color", Color) = (1, 1, 1, 1)
        _LineAlpha("Line Alpha", Range(0, 1)) = 1
        _LineCount("Line Count", Range(1, 32)) = 8
        _LineHeight("Line Height", Range(0, 1)) = 0.05
        _ScrollSpeed("Scroll Speed", Range(-5, 5)) = -1
    }

    SubShader
    {
        Tags
        {
            "RenderPipeline" = "UniversalPipeline"
            "RenderType" = "Transparent"
            "Queue" = "Transparent"
        }

        Pass
        {
            Name "Unlit"
            Tags { "LightMode" = "UniversalForward" }
            Blend SrcAlpha OneMinusSrcAlpha
            Cull Off
            ZWrite Off

            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

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
                float3 positionOS : TEXCOORD2;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _BaseAlpha;
                float4 _RimColor;
                float _RimPower;
                float4 _LineColor;
                float _LineAlpha;
                float _LineCount;
                float _LineHeight;
                float _ScrollSpeed;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.positionWS = TransformObjectToWorld(IN.positionOS.xyz);
                OUT.positionOS = IN.positionOS.xyz;
                OUT.normalWS   = TransformObjectToWorldNormal(IN.normalOS);
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                float scanLine = frac(IN.positionOS.y * _LineCount + _Time.y * _ScrollSpeed);
                float scanStep = step(scanLine, _LineHeight);
                
                float3 color = lerp(_BaseColor.rgb, _LineColor.rgb, scanStep);
                float alpha = lerp(_BaseAlpha, _LineAlpha, scanStep);
                
                return float4(color, alpha);
            }
            ENDHLSL
        }
    }
}