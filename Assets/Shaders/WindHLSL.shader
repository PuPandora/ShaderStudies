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
            //
            // Varyings vert(Attributes IN)
            // {
            //     Varyings OUT;
            //     float swayMask = (IN.positionOS.x + 5) / 10;
            //     swayMask = saturate(swayMask);
            //     swayMask = pow(swayMask, _MaskPower);
            //     IN.positionOS.y += sin(_Time.y * _Speed + IN.positionOS.x) * swayMask;
            //     OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
            //     OUT.mask = swayMask;
            //     return OUT;
            // }
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            
            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                
                // SwayMask 깃발 흔들림 정도 + 디버그 표시
                float swayMask = (IN.positionOS.x + 5) / 10; // -5 ~ +5 Plane 고유 position.x 크기
                swayMask = saturate(swayMask);
                swayMask = pow(swayMask, _MaskPower);
                OUT.mask = swayMask;
                
                // 깃발처럼 흔들리는 부분
                // 일단 sin으로 움직이는 것 부터
                // IN.positionOS.x += sin(_Time.y) * 10;
                // X -90 으로 Rotate 되어있으니까
                // 앞면이 위를보고 있는 상황.
                // 그러면 각 정점을. 무엇을 기준으로 위치를 구분하고 어느 방향으로 흔든다?
                // 이건 유니티에서 Local로 보는게 편함. 익숙치 않다면
                // 확인해봤을 때, Y축이 측면, X축 좌우, Z축이 상하다.
                // 내가 보는 기준 좌우의 정점이 각자 다른 갚을 가지고 앞 뒤로 움직였으면 좋겠다.
                
                // 그렇다면 y축을 기준으로 흔든다. x축 위치 기준으로 다른 시작 값을 가진다.
                // + SwayMask 기준으로 검은색 부분은 덜 흔들리게. 0은 안 흔들리게 해야함
                IN.positionOS.y += sin(_Time.y * _Speed + IN.positionOS.x) * swayMask;
                // 오케이 이정도면 됐다.
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