Shader "Unlit/FlyingCarpetShader"
{
	Properties
	{
		[Header(Main Color)]
		[Toggle] _UseColor("Enabled?", Float) = 0
		_Color("Main Color", Color) = (1,1,1,1)
		[Space(20)]

		[Header(Diffuse Texture)]
		[Toggle] _UseMainTex("Enabled?", Float) = 1
		[NoScaleOffset] _MainTex("Base (RGB)", 2D) = "white" {}
		[Space(20)]
		[Header(Waves)]
		_WaveStrength("Wave Strength", Float) = 0
		_WaveFrequency("Wave Frequency", Float) = 0
	}
	SubShader
	{
		Tags { "RenderType"="Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma shader_feature _USECOLOR_ON
			#pragma shader_feature _USEMAINTEX_ON

			#pragma vertex vert
			#pragma fragment frag
			
			#include "UnityCG.cginc"

			#if _USEMAINTEX_ON
				UNITY_DECLARE_TEX2D(_MainTex);
			#endif

			#if _USECOLOR_ON
				float4 _Color;
			#endif

			float _WaveStrength;
			float _WaveFrequency;

			struct appdata
			{
				float4 vertex : POSITION;
				float3 normal: NORMAL;
				float2 uv : TEXCOORD0;
			};

			struct v2f
			{
				float2 uv : TEXCOORD0;
				half3 normal : TEXCOORD1;
				half3 viewDir : TEXCOORD2;
				float4 vertex : SV_POSITION;
			};
			
			void modulateVertex(inout float3 vertex) {
				half modulation = sin(_Time * _WaveFrequency + vertex.z) * _WaveStrength;
				float shift = cos(_Time * _WaveFrequency + vertex.x);

				vertex.y += shift * modulation;
			}

			v2f vert (appdata v)
			{
				v2f o;

				o.uv = v.uv;

				float4 worldPos = mul(unity_ObjectToWorld, v.vertex);
				o.viewDir = _WorldSpaceCameraPos - worldPos.xyz;

				float3 v1 = v.vertex.xyz;
				float3 v2 = v1;
				float3 v3 = v1;

				modulateVertex(v1);
				o.vertex = UnityObjectToClipPos(v1);

				//To compute the normal, we need to get the derivatives on the X/Z plane
				//relative to this vertex
				v2.x += 0.01;
				modulateVertex(v2);

				v3.z += 0.01;
				modulateVertex(v3);

				o.normal = normalize(cross(normalize(v2 - v1), normalize(v1 - v3)));
				if (v.normal.y < 0.)
					o.normal = -o.normal;

				o.normal = UnityObjectToWorldNormal(o.normal);

				return o;
			}
			
			fixed4 frag (v2f i) : SV_Target
			{
				#if _USEMAINTEX_ON
					float4 color = UNITY_SAMPLE_TEX2D(_MainTex, i.uv);
				#else
					float4 color = 1;
				#endif

				#if _USECOLOR_ON
					color *= _Color;
				#endif

				float fresnel = 1. - max(0., dot(normalize(i.viewDir), normalize(i.normal)));
				fresnel = pow(fresnel, 8.0);

				float diffuse = dot(i.normal, _WorldSpaceLightPos0.xyz);

				return color * diffuse + fresnel;
			}
			ENDCG
		}
	}
}
