Shader "ShaderStudies/WindHLSL"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _MaskPower("Mask Power", Range(0, 8)) = 1
        _Speed("Speed", Range(0, 10)) = 1
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"

            struct Attributes
            {
                float4 positionOS : POSITION;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float mask : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float _MaskPower;
                float _Speed;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                float swayMask = (IN.positionOS.x + 5) / 10;
                swayMask = saturate(swayMask);
                swayMask = pow(swayMask, _MaskPower);
                IN.positionOS.y += sin(_Time.y * _Speed + IN.positionOS.x) * swayMask;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.mask = swayMask;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // 디버그 범위 확인용 그리기
                return float4(IN.mask, IN.mask, IN.mask, 1);
                return _BaseColor;
            }
            ENDHLSL
        }
    }
}