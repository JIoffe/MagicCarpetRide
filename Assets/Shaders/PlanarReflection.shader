// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Shader specifically intended for the projection of a planar reflection
// Supports diffuse color, texture, and glossiness options
Shader "Custom/EFfects/Reflective/PlanarReflection"
{
	Properties
	{
		[Header(Diffuse Color)]
		[Toggle] _UseColor("Enabled?", Float) = 1
		_Color("Diffuse Color", Color) = (1,1,1,1)
		[Space(20)]

		[Header(Diffuse Texture)]
		[Toggle] _UseMainTex("Enabled?", Float) = 0
		[NoScaleOffset] _MainTex("Diffuse Texture", 2D) = "white" {}
		_DiffuseTiling("Texture Tiling", Float) = 1
		[Space(20)]

		_Reflectiveness("Reflective Multiplier", Float) = 2.0
		[Space(20)]

		[Header(Glossy Surface)]
		[Toggle] _Glossy("Enable Glossiness?", Float) = 0
		_Smoothness("Smoothness", Range(0,1)) = 0.75
		[Space(20)]

		[Header(Shading)]
		[Toggle] _UseShading("Enabled?", Float) = 0
		[Space(20)]

		_FrameBuffer("Reflection Render Target", 2D) = "white" {}
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
			
			#pragma shader_feature _USECOLOR_ON
			#pragma shader_feature _USEMAINTEX_ON
			#pragma shader_feature _GLOSSY_ON
			#pragma shader_feature _SHADING_ON

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float2 uv : TEXCOORD0;
				float uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				float4 worldPos : TEXCOORD1;
				float4 vertex : SV_POSITION;
				#if _SHADING_ON
				float2 lightmapUV : TEXCOORD2;
				#endif
			};

			#if _USEMAINTEX_ON
				UNITY_DECLARE_TEX2D(_MainTex);
				float _DiffuseTiling;
			#endif

			uniform sampler2D _FrameBuffer;

			//Project a world position into the view of a mirror's camera
			float4x4 _ReflectionCameraToWorld;
			float4 _Color;
			float _Reflectiveness;
			float _Smoothness;
			

			#if _GLOSSY_ON
			float4 getGlossyReflection(float2 projectedTexCoords) {
				float4 reflection = float4(0., 0., 0., 0.);

				//Blur texture to simulate glossiness
				int x;

				for (x = -1; x < 2; x++)
					reflection += tex2D(_FrameBuffer, float2(projectedTexCoords.x + 0.006 * float(x), projectedTexCoords.y));

				for (x = -1; x < 2; x++)
					reflection += tex2D(_FrameBuffer, float2(projectedTexCoords.x, projectedTexCoords.y + 0.006 * float(x)));

				reflection /= 6.0;

				return reflection;
			}
			#endif

			v2f vert (appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.uv = v.uv;
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);
				#if _SHADING_ON
					o.lightmapUV = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
				#endif
				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				float4 projectionSamplingPosition = mul(_ReflectionCameraToWorld, i.worldPos);

				half halfW = projectionSamplingPosition.w * 2.;

				float2 projectedTexCoords;

				projectedTexCoords.x = projectionSamplingPosition.x / halfW + 0.5;
				projectedTexCoords.y = projectionSamplingPosition.y / halfW + 0.5;
			
				//If glossiness is enabled, blur out the texture. Otherwise, just sample a perfect reflection
				#if _GLOSSY_ON
					float4 reflection = getGlossyReflection(projectedTexCoords);
				#else
					float4 reflection = tex2D(_FrameBuffer, projectedTexCoords);
				#endif

				half fresnel;
				if (_Reflectiveness > 0.99)
					fresnel = 1;
				else {
					half3 viewDir = normalize(_WorldSpaceCameraPos - i.worldPos.xyz);
					fresnel = smoothstep(0., 1. - _Reflectiveness, (1. - dot(viewDir, float3(0., 1., 0.))));
				}

				float4 color;

				#if _USEMAINTEX_ON
					color = UNITY_SAMPLE_TEX2D(_MainTex, frac(i.worldPos.xz * _DiffuseTiling));
				#else
					color = 1;
				#endif

				#if _USECOLOR_ON
					color *= _Color;
				#endif

				#if _SHADING_ON
					color.rgb *= DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lightmapUV));
				#endif

				return lerp(color, reflection, fresnel);
			}


			ENDCG
		}
	}
}
