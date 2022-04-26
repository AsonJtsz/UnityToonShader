Shader "Unlit/ToonShader"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _BaseLight("Base Light", range(0, 1)) = 0.5

        [Space(30)]
        _DirectionalLightSmoothHigh("Directional Light Smooth High", range(0, 1)) = 0.01

        [Space(30)]
        _AmbientLightColor("Ambient Light Color", Color) = (0, 0, 0, 0)
        _AmbientLightIntensity("Ambient Light Intensity", range(0, 1)) = 0

        [Space(30)]
        _SpecularColor("Specular Color", Color) = (1, 1, 1, 1)
        _SpecularHardness("Specular Hardness", float) = 32
        _SpecularSmoothLow("Specular Toon Low", range(0, 1)) = 0.005
        _SpecularSmoothHigh("Specular Toon High", range(0, 1)) = 0.05

        _RimColor("Rim Color", Color) = (1, 1, 1, 1)
        _RimAmount("Rim Amount", float) = 0.7
        _RimThreshhold("Rim Threshold", range(0, 10)) = 0.1

        // _DividLineSpec("DividLine of Specular", Range(0.5, 1.0)) = 0.8
        _Glossiness ("Smoothness Scale", Range(0,1)) = 0.5

        [Space(30)]
        _FresnelEff("Fresnel Effect Coefficient", Range(0, 1)) = 0.5
        //_FresnelColor("Fresnel Color", Color) = (1, 1, 1, 1)

        [Space(30)]
        _SSSColor("Subsurface Scattering Color", Color) = (1,0,0,1)
		_SSSWeight("Weight of SSS", Range(0,1)) = 0.0
		_SSSSize("Size of SSS", Range(0,1)) = 0.0
		_SSForwardAtt("Atten of SS in forward Dir", Range(0,1)) = 0.5
        _DividSharpness("Sharpness of Divide Line", Range(0.2,5)) = 1.0



    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_fwdbase

            #include "UnityCG.cginc"
            #include "AutoLight.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal: NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 pos : SV_POSITION;
                float3 worldNormal : NORMAL;
                float3 viewDir : TEXCOORD1;
                //SHADOW_COORDS(2)
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _BaseLight;
            float _DirectionalLightSmoothHigh;

            float4 _AmbientLightColor;
            float _AmbientLightIntensity;

            float4 _SpecularColor;
            float _SpecularHardness;
            float _SpecularSmoothLow;
            float _SpecularSmoothHigh;

            float4 _RimColor;
            float _RimAmount;
            float _RimThreshhold;

            float _FresnelEff;
            //float _FresnelColor;

            fixed4 _SSSColor;
		    half _SSSWeight;
		    half _SSSSize;
		    half _SSForwardAtt;
            float _DividSharpness;

            float _Glossiness;


            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.worldNormal = UnityObjectToWorldNormal(v.normal);
                o.viewDir = WorldSpaceViewDir(v.vertex);
                //TRANSFER_SHADOW(o)
                return o;
            }

            // float toon(float NdotL)
            // {
            //     float directionalLightIntensity = max(0, NdotL);
            //     return ceil(NdotL / 0.5) / 2;
            // }

            // float D_GGX(float a2, float NoH) {
		    //     float d = (NoH * a2 - NoH) * NoH + 1;
		    //     return a2 / (3.14159 * d * d);
	        // }

            // float sigmoid(float x, float center, float sharp) {
            //     float s;
		    //     s = 1 / (1 + pow(100000, (-3 * sharp * (x - center))));
		    //     return s;
	        // }

            float3 Fresnel_schlick(float VoN, float3 rF0) {
		        return rF0 + (1 - rF0) * pow(1 - VoN, 5);
	        }

	        float3 Fresnel_extend(float VoN, float3 rF0) {
		        return rF0 + (1 - rF0) * pow(1 - VoN, 3);
	        }

            float Gaussion(float x, float center, float var) {
		        return pow(2.718, -1 * pow(x - center, 2) / var);
	        }

            fixed4 frag (v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                float3 normal = normalize(i.worldNormal);
                float NdotL = dot(normal, _WorldSpaceLightPos0.xyz);

                

                // Boundary
                //float shadow = SHADOW_ATTENUATION(i);

                //return half4(ceil(shadow * NdotL).xxx, 1);
                float shadow = 1;

                half mid = smoothstep(0, 0+_DirectionalLightSmoothHigh, NdotL);
                half low = smoothstep(-0.6, -0.6+_DirectionalLightSmoothHigh, NdotL);
                //half mid = smoothstep(0, 0+_DirectionalLightSmoothHigh, NdotL * shadow);
                //half low = smoothstep(-0.6, -0.6+_DirectionalLightSmoothHigh, NdotL * shadow);
                //return half4(mid.xxx, 1);
                //return half4(low.xxx, 1);
                half light = mid;
                //return half4(light.xxx, 1);
                half dark1 = (low - mid) ;
                //return half4(dark1.xxx, 1);
                half dark2 = 1 - low;
                //return half4(dark2.xxx, 1);
                float directionalLightIntensity = light * 1.0 + dark1 * 0.5 + dark2 * 0.2;
                //directionalLightIntensity *= shadow * NdotL;

                
                // half roughness = 0.95*( 1 - _Glossiness);
			    // half _BoundSharp = 9.5 * pow(roughness - 1, 2) + 0.5;
                // half diffuseLumin2 = (0.5 + 0.25) / 2;

                // half MidSig = sigmoid(NdotL, 0, _BoundSharp * _DividSharpness);
                // half DarkSig = sigmoid(NdotL, -0.5, _BoundSharp * _DividSharpness);
                // half MidLWin = MidSig;
                // half MidDWin = DarkSig - MidSig;
                // half DarkWin = 1 - DarkSig;
                //-------------------
                //float directionalLightIntensity = MidLWin * 1.0 + MidDWin * 0.5 + DarkWin * 0.2;

                float4 ambientLight = _AmbientLightColor * _AmbientLightIntensity;

                float3 viewDir = normalize(i.viewDir);
                float3 halfVector = normalize(_WorldSpaceLightPos0 + viewDir);
                float NdotH =  dot(halfVector, normal);
                float specularLightIntensity = pow(saturate(NdotH), _SpecularHardness);
                specularLightIntensity = smoothstep(_SpecularSmoothLow, _SpecularSmoothHigh, specularLightIntensity * shadow);

                // old rim
                float VdotN = dot(viewDir, normal);
                float4 rimDot = 1 - VdotN;
                float rimIntensity = rimDot * pow(NdotL, _RimThreshhold) ;
                rimIntensity = smoothstep(_RimAmount - 0.01, _RimAmount + 0.01, rimIntensity);
                float4 rim = rimIntensity * _RimColor;
                //------------------

                float VdotL = dot(viewDir, normalize(_WorldSpaceLightPos0));
                half3 fresnel = Fresnel_extend(VdotN, float3(0.1, 0.1, 0.1));
                half3 fresnelResult = _FresnelEff * fresnel * (1 - VdotL) / 2;
                //half3 fresnelResult = _FresnelColor * _FresnelEff * fresnel * (1 - VdotL) / 2;
                //return half4(fresnelResult.xxx, 1);

                half SSMidLWin = Gaussion(NdotL, 0, _SSForwardAtt * _SSSSize);
                half SSMidDWin = Gaussion(NdotL, 0, _SSSSize);
                half diffuseLumin = (0.5 + 0.25) / 2;
                half3 SSLumin1 = (light * diffuseLumin) * _SSForwardAtt * SSMidLWin;
                half3 SSLumin2 = ((dark1+ dark2) * diffuseLumin) * SSMidDWin;
                half3 SS = _SSSWeight * (SSLumin1 + SSLumin2) * _SSSColor.rgb;
                //return half4(SS, 1);

                float4 finalIntensity = (directionalLightIntensity + specularLightIntensity + ambientLight) * (1 - _BaseLight) + _BaseLight;
                return col * finalIntensity +half4(fresnelResult, 1) + half4(SS, 1); 
            }
            ENDCG
        }
        //UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}
