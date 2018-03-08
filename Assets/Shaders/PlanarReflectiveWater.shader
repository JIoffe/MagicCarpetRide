// Upgrade NOTE: replaced 'mul(UNITY_MATRIX_MVP,*)' with 'UnityObjectToClipPos(*)'

Shader "Custom/EFfects/Reflective/PlanarReflectiveWater"
{
	Properties
	{
		[Header(Water Surface)]
		[NoScaleOffset] _WaterNormal("Water Surface Normal Map", 2D) = "white" {}
		_Tiling("Texture Tiling", Float) = 1
		_Speed("Surface movement Speed", Float) = 1
		_Perturbance("Perturbance Multiplier", Float) = 2.0
		[Space(20)]

		_FrameBuffer("Reflection Render Target", 2D) = "white" {}
	}
	SubShader
	{
		Tags{ "RenderType" = "Opaque" }
		LOD 100

		Pass
		{
			CGPROGRAM
			#pragma vertex vert
			#pragma fragment frag

			#include "UnityCG.cginc"

			struct appdata
			{
				float4 vertex : POSITION;
				float uv2 : TEXCOORD1;
			};

			struct v2f
			{
				float4 worldPos : TEXCOORD1;
				float4 vertex : SV_POSITION;
			};

			uniform sampler2D _WaterNormal;
			uniform sampler2D _FrameBuffer;
			uniform float _Perturbance;
			uniform float _Tiling;
			uniform float _Speed;

			//Project a world position into the view of a mirror's camera
			float4x4 _ReflectionCameraToWorld;

			v2f vert(appdata v)
			{
				v2f o;
				o.vertex = UnityObjectToClipPos(v.vertex);
				o.worldPos = mul(unity_ObjectToWorld, v.vertex);

				return o;
			}

			float3 getNormal(float2 uv) {
				float3 n1 = UnpackNormal(tex2D(_WaterNormal, uv + float2(_Time.y * _Speed, 0.)));
				float3 n2 = UnpackNormal(tex2D(_WaterNormal, uv - float2(0., _Time.y * _Speed * 0.8)));

				return normalize(n1 + n2);
			}

			float2 getProjectedTexCoords(float4 pos) {
				float4 projectionSamplingPosition = mul(_ReflectionCameraToWorld, pos);
				half halfW = projectionSamplingPosition.w * 2.;

				float2 projectedTexCoords;
				projectedTexCoords.x = projectionSamplingPosition.x / halfW + 0.5;
				projectedTexCoords.y = projectionSamplingPosition.y / halfW + 0.5;

				return projectedTexCoords;
			}

			fixed4 frag(v2f i) : SV_Target
			{
				float3 normal = getNormal(i.worldPos.xz * _Tiling);
				float2 projectedTexCoords = getProjectedTexCoords(i.worldPos);
				projectedTexCoords += normal.xy * _Perturbance;

				float4 reflection = tex2D(_FrameBuffer, projectedTexCoords);

				return reflection + abs(normal.y * 2.);
			}


			ENDCG
		}
	}
}
