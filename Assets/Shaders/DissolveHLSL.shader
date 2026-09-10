Shader "ShaderStudies/DissolveHLSL"
{
    Properties
    {
        _BaseColor("Base Color", Color) = (1, 1, 1, 1)
        _Cutoff("Cutoff", Range(0, 1)) = 0.5
        _NoiseScale("Noise Scale", Float) = 10
        _NoiseSpeed("Noise Speed", Float) = 0.2
        _Offset("Offset", Float) = 0.1
        [HDR]_DissolveColor("Dissolve Color", Color) = (1, 1, 1, 1)
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
                float2 uv         : TEXCOORD0;
            };

            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv         : TEXCOORD0;
            };

            CBUFFER_START(UnityPerMaterial)
                float4 _BaseColor;
                float4 _DissolveColor;
                float _Cutoff;
                float _NoiseSpeed;
                float _NoiseScale;
                float _Offset;
            CBUFFER_END

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionCS = TransformObjectToHClip(IN.positionOS.xyz);
                OUT.uv = IN.uv;
                return OUT;
            }
            
            // 좌표 하나 → 0~1 난수 하나 반환
            float hash21(float2 p)
            {
                p = frac(p * float2(123.34, 456.21));
                p += dot(p, p + 45.32);
                return frac(p.x * p.y);
            }

            // 값 노이즈 — 격자 꼭짓점의 난수를 부드럽게 보간
            float valueNoise(float2 uv)
            {
                float2 i = floor(uv);
                float2 f = frac(uv);
                f = f * f * (3.0 - 2.0 * f);          // 부드러운 보간 곡선

                float a = hash21(i);
                float b = hash21(i + float2(1, 0));
                float c = hash21(i + float2(0, 1));
                float d = hash21(i + float2(1, 1));

                return lerp(lerp(a, b, f.x), lerp(c, d, f.x), f.y);
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // Dissolve 효과
                float noiseResult = valueNoise(IN.uv * _NoiseScale + _Time.y * _NoiseSpeed);
                clip(noiseResult - _Cutoff);
                // 띠 구하기
                float dissolveLine = step (_Cutoff, noiseResult) - step(_Cutoff + _Offset, noiseResult);
                
                return _BaseColor + dissolveLine * _DissolveColor;
            }
            ENDHLSL
        }
    }
}