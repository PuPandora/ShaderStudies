Shader "ShaderStudies/WindHLSL"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _MaskPower("Mask Power", Range(0, 8)) = 1
        _Speed("Speed", Range(0, 10)) = 1
        [Toggle(_DEBUG_MASK)]_DebugMask("Debug Mask", float) = 0
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
            #pragma shader_feature_local _DEBUG_MASK

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
                
                // SwayMask 깃발 흔들림 정도 + 디버그 표시
                float swayMask = (IN.positionOS.x + 5) / 10; // -5 ~ +5 Plane 고유 position.x 크기
                swayMask = saturate(swayMask);
                swayMask = pow(swayMask, _MaskPower);
                OUT.mask = swayMask;
                
                // 그렇다면 y축을 기준으로 흔든다. x축 위치 기준으로 다른 시작 값을 가진다.
                // + SwayMask 기준으로 검은색 부분은 덜 흔들리게. 0은 안 흔들리게 한다.
                IN.positionOS.y += sin(_Time.y * _Speed + IN.positionOS.x) * swayMask;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                return OUT;
            }
            
            half4 frag(Varyings IN) : SV_Target
            {
                #ifdef _DEBUG_MASK
                // 디버그 범위 확인용 그리기
                return float4(IN.mask, IN.mask, IN.mask, 1);
                #endif
                return _BaseColor;
            }
            ENDHLSL
        }
    }
}