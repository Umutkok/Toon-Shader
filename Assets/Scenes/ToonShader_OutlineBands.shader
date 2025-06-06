Shader "Custom/ToonShader_Outline_8Bands_Smooth"
{
    Properties
    {
        _Color("Base Color", Color) = (1,1,1,1)
        _OutlineColor("Outline Color", Color) = (0,0,0,1)
        _OutlineWidth("Outline Width", Float) = 0.05
    }

    SubShader
    {
        Tags { "RenderType"="Opaque" }

        // PASS 1: Outline
        Pass
        {
            Name "Outline"
            Cull Front
            ZWrite On
            ZTest LEqual

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _OutlineColor;
            float _OutlineWidth;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
            };

            v2f vert(appdata v)
            {
                v2f o;
                float3 norm = normalize(UnityObjectToWorldNormal(v.normal));
                float3 offsetPos = v.vertex.xyz + norm * _OutlineWidth;
                o.pos = UnityObjectToClipPos(float4(offsetPos,1));
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                return _OutlineColor;
            }
            ENDCG
        }

        // PASS 2: Toon Lighting 8 bands with smoothstep
        Pass
        {
            Name "ToonShading"
            Tags { "LightMode"="ForwardBase" }
            Cull Back

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #include "UnityCG.cginc"

            fixed4 _Color;

            struct appdata
            {
                float4 vertex : POSITION;
                float3 normal : NORMAL;
            };

            struct v2f
            {
                float4 pos : SV_POSITION;
                float3 worldNormal : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag(v2f i) : SV_Target
            {
                float3 lightDir = normalize(_WorldSpaceLightPos0.xyz);
                float NdotL = saturate(dot(normalize(i.worldNormal), lightDir));

                // 8 ton için eşik değerler (0.0 - 1.0 aralığında)
                float intensity = 0;

                intensity += smoothstep(0.0, 0.125, NdotL) * 0.125;
                intensity += smoothstep(0.125, 0.25, NdotL) * 0.125;
                intensity += smoothstep(0.25, 0.375, NdotL) * 0.125;
                intensity += smoothstep(0.375, 0.5, NdotL) * 0.125;
                intensity += smoothstep(0.5, 0.625, NdotL) * 0.125;
                intensity += smoothstep(0.625, 0.75, NdotL) * 0.125;
                intensity += smoothstep(0.75, 0.875, NdotL) * 0.125;
                intensity += smoothstep(0.875, 1.0, NdotL) * 0.125;

                return _Color * intensity;
            }
            ENDCG
        }
    }
}