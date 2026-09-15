Shader "ShaderStudies/WindHLSL"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _MaskPower("Mask Power", Range(0, 8)) = 1
        _Speed("Speed", Range(0, 10)) = 1
        _Amplitude("Amplitude", Range(0, 3)) = 1
        [Toggle(_DEBUG_MASK)]_DebugMask("Debug Mask", float) = 0
        _ExtentX("Extents X", Float) = 0.5
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
                // 진폭
                float _Amplitude;
                // X 길이 절반
                float _ExtentX;
            CBUFFER_END
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                float extentX = max(_ExtentX, 0.0001);
                // SwayMask 깃발 흔들림 정도 + 디버그 표시
                float swayMask = (IN.positionOS.x + extentX) / (extentX * 2);
                swayMask = pow(saturate(swayMask), _MaskPower);
                OUT.mask = swayMask;
                
                // 버텍스 움직이기. 깃발 흔들림
                float wave2SpeedScale = 1.3;
                float wave2Weight = 0.4;
                float wave = sin(_Time.y * _Speed + IN.positionOS.x);
                float wave2 = sin(_Time.y * _Speed * wave2SpeedScale + IN.positionOS.z);
                IN.positionOS.y += (wave + wave2 * wave2Weight) * _Amplitude * swayMask;
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