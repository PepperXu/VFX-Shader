Shader "vfx-hl/basic-add"
{
	Properties
	{
		[HDR] _BaseColor	        ("Color", Color)                            = (1, 1, 1, 1)
		_BaseMap 		            ("Texture", 2D)                             = "white" {}
		_MainRotation	            ("├ Main Rotation", Float)                  = 0.0
		[Toggle] _MAINROTATIONSPEED ("├ Enable Main Rotation Speed", Int)       = 0
		_UVScrollX		            ("├ Main UV X Scroll", Float)               = 0.0
		_UVScrollY		            ("└ Main UV Y Scroll", Float)               = 0.0
		_CutTex			            ("Cutout (A)", 2D)                          = "white" {}
		_Cutoff			            ("Alpha Cutoff", Range(0.0, 1.0)) 	       = 0.0
		_CutRotation                ("Cut Rotation", Float)                     = 0.0
		_UVCutScrollX               ("Cut UV X Scroll", Float)                  = 0.0
		_UVCutScrollY               ("Cut UV Y Scroll", FLoat)                  = 0.0
		_UVMirrorX                  ("UV Mirror X", Range(0.0, 1.0))            = 0.0
		_UVMirrorY                  ("UV Mirror Y", Range(0.0, 1.0))            = 0.0
		_EmissionGain               ("Emission Gain", Range(0, 1))              = 0.0
		[Toggle] _USESHEET          ("Sheet Animation", Float)                  = 0.0
		_xx                         ("├ Tiles X", float)                        = 1.0
		_yy                         ("├ Tiles Y", float)                        = 1.0
		_Speed                      ("└ FPS", float)                            = 30.0
		[HideInInspector] _QueueOffset("Queue offset", Int) = 0
	}
	SubShader
	{
		Tags { "RenderType" = "Opaque" "IgnoreProjector" = "True" "Queue" = "Transparent" "RenderPipeline" = "UniversalPipeline" "PreviewType"="Plane"}
		LOD 100
		Blend SrcAlpha One
		Cull Off 
		Lighting Off 
		ZWrite Off
		Pass
		{
			Name "Pass"
		  HLSLPROGRAM
			#pragma prefer_hlslcc gles
			#pragma exclude_renderers d3d11_9x
			#pragma vertex vert
			#pragma fragment frag
			#pragma shader_feature _ALPHATEST_ON
			#pragma multi_compile_fog
			#pragma multi_compile_instancing
			#pragma shader_feature Enable_AlphaMask
			#pragma shader_feature Enable_UVRotation
			#pragma shader_feature _MAINROTATIONSPEED_ON
			#pragma shader_feature Enable_UVScroll
			#pragma shader_feature Enable_UVMirror
			#pragma shader_feature Enable_Bloom
			#pragma shader_feature _USESHEET_ON			
			#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
			TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
			TEXTURE2D(_CutTex); SAMPLER(sampler_CutTex);
			CBUFFER_START(UnityPerMaterial)
				half4 _BaseColor;
				float4 _BaseMap_ST;
				half _Cutoff;
				#ifdef Enable_AlphaMask
					float4 _CutTex_ST;
				#endif
				#ifdef Enable_UVRotation
					float _MainRotation;
					float _CutRotation;
				#endif
				#ifdef Enable_UVScroll
					float _UVScrollX;
					float _UVScrollY;
					float _UVCutScrollX;
					float _UVCutScrollY;
				#endif
				#ifdef Enable_UVMirror
					float _UVMirrorX;
					float _UVMirrorY;
				#endif
				#ifdef Enable_Bloom
					float _EmissionGain;
				#endif
				#if _USESHEET_ON
					half _xx;
					half _yy;
					half _Speed;
				#endif			
			CBUFFER_END
			struct Attributes
			{
				half4  color  			: COLOR;
				float4 positionOS       : POSITION;
				float2 uv               : TEXCOORD0;
				UNITY_VERTEX_INPUT_INSTANCE_ID
			};
			struct Varyings
			{
				half4  color  	     : COLOR;
				float4 vertex        : SV_POSITION;
				float2 uv            : TEXCOORD0;
				#if Enable_AlphaMask
					half2 uv_CutOut  : TEXCOORD1;
					float fogCoord   : TEXCOORD2;
				#else
					float fogCoord   : TEXCOORD1;
				#endif
				UNITY_VERTEX_INPUT_INSTANCE_ID
				UNITY_VERTEX_OUTPUT_STEREO
			};
			Varyings vert(Attributes input)
			{
				Varyings output = (Varyings)0;
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_TRANSFER_INSTANCE_ID(input, output);
				VertexPositionInputs vertexInput = GetVertexPositionInputs(input.positionOS.xyz);
				output.vertex   = vertexInput.positionCS;
				output.uv       = TRANSFORM_TEX(input.uv, _BaseMap);
				output.fogCoord = ComputeFogFactor(vertexInput.positionCS.z);
				output.color = input.color;
				#ifdef Enable_UVMirror
					float2 t = input.uv;
					float2 len = {_UVMirrorX, _UVMirrorY};
					float2 mirrorTextCoords = abs(t - len);
				#else
					float2 mirrorTextCoords = input.uv;
				#endif
				#ifdef Enable_UVScroll
					float2 scroll = float2(_UVScrollX, _UVScrollY) * _Time.y;
					output.uv = (mirrorTextCoords.xy + scroll) * _BaseMap_ST.xy + _BaseMap_ST.zw;
				#else
					output.uv = mirrorTextCoords.xy * _BaseMap_ST.xy + _BaseMap_ST.zw;
				#endif
				#ifdef Enable_UVRotation
					output.uv.xy -= 0.5;
					float s = 0;
					float c = 0;
					#ifdef _MAINROTATIONSPEED_ON
						s = sin(_MainRotation * _Time.y);
						c = cos(_MainRotation * _Time.y);
					#else
						s = sin(radians(_MainRotation));
						c = cos(radians(_MainRotation));
					#endif	
					float2x2 rotationMatrix = float2x2(c, -s, s, c);
					output.uv.xy = mul(output.uv.xy, rotationMatrix);
					output.uv.xy += 0.5;
				#endif
				#if Enable_AlphaMask
					#ifdef Enable_UVScroll
						scroll = float2(_UVCutScrollX, _UVCutScrollY) * _Time.y;
						output.uv_CutOut = (input.uv + scroll) * _CutTex_ST.xy + _CutTex_ST.zw;
					#else
						output.uv_CutOut = input.uv * _CutTex_ST.xy + _CutTex_ST.zw;
					#endif
					#ifdef Enable_UVRotation
						output.uv_CutOut.xy -= 0.5;
						s = sin(radians(_CutRotation));
						c = cos(radians(_CutRotation));
						rotationMatrix = float2x2(c, -s, s, c);
						output.uv_CutOut.xy = mul(output.uv_CutOut.xy, rotationMatrix);
						output.uv_CutOut.xy += 0.5;
					#endif
				#endif
				return output;
			}
			half4 frag(Varyings input) : SV_Target
			{
				UNITY_SETUP_INSTANCE_ID(input);
				UNITY_SETUP_STEREO_EYE_INDEX_POST_VERTEX(input);
				half4 texColor = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
				half4 color = half4(0,0,0,0);
					#if _USESHEET_ON
						float row = floor(_Time.y * _Speed);
						color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, saturate(input.uv) * float2(1 / _xx, 1 / _yy) + float2(frac(row / _xx), (1 - ((floor(row / _xx)) + 1) / _yy)));
					#else
						color = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
					#endif
					#ifdef Enable_Bloom
						#if _USESHEET_ON
							color *=        input.color * (exp(_EmissionGain * 5.0f));
						#else
							color  = 2.0f * input.color * SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv) * (exp(_EmissionGain * 5.0f));
						#endif
					#else
						#if _USESHEET_ON
							color *=        input.color;
						#else
							color  = 2.0f * input.color * SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, input.uv);
						#endif
					#endif
					#if Enable_AlphaMask
						half ca = SAMPLE_TEXTURE2D(_CutTex, sampler_CutTex, input.uv_CutOut).a;
						color.a *= ca;
						color.a = saturate((ca - _Cutoff) * 100) * color.a;
					#endif
					color.rgb = MixFog(color.rgb, input.fogCoord);
					color *= _BaseColor;
					return color;
			}
		  ENDHLSL
		}
	}
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "Art.VfxHLGUI"
}