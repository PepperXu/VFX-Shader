﻿Shader "vfx/general"
{
	Properties
	{
		[Header(Render Mode)]
		[Enum(Additive,0,Blend_Add,1,Alpha_Blended,2)] _BlendMode ("Blend Mode", Int) 		= 0
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendSrc ("Blend mode Source", Int) 		= 1
		[Enum(UnityEngine.Rendering.BlendMode)] _BlendDst ("Blend mode Destination", Int) 	= 1
		[Enum(UnityEngine.Rendering.CullMode)] 	_Cull ("Cull Mode", Int) 					= 0

		[Header(Primary)]
		[HDR]_BaseColor                     	("Tint Color", Color)                       = (1, 1, 1, 1)
		[MainTexture]_BaseMap                   ("Base (RGB) Trans (A)", 2D)                = "white" {}
		_MainRotation                          	("├ Main Rotation", Float)                  = 0.0
		_UVScrollX                             	("├ Main UV X Scroll", Float)               = 0.0
		_UVScrollY                             	("├ Main UV Y Scroll", Float)               = 0.0
		[Toggle] _USEPOS                		("└ Use Main Posterize", Int)        		= 0
		_Posterize                      		(" ╠ Posterize", Range(2, 50))          	= 2.0
		[Toggle] _USEMIRROR               		("└ Use Mirror", Int)     					= 0
		_UVMirrorX                             	(" ╠ UV Mirror X", Range(0.0, 1.0))         = 0.0
		_UVMirrorY                             	(" ╚ UV Mirror Y", Range(0.0, 1.0))         = 0.0
		
		[Header(Rim (Incompatible with Particles))]
		[Toggle] _USERIM 						("Use Rim", Int)							= 0
		_RimRange       						("├ Rim Range", Range(0.1, 10))           	= 0
		_RimPower      							("├ Rim Power", Range(0, 5))           		= 0
		[HDR]_RimColor        					("└ Rim Color", Color)                 		= (1,1,1,1)
		
		[Header(Mask)]
		[Toggle] _USEMASK						("Use Mask", Int)        					= 0
		_CutTex                                	("├ Mask Texture", 2D)                      = "white" {}
		_CutRotation                           	("├ Mask Rotation", Float)                  = 0.0
		_UVCutScrollX                          	("├ Mask UV X Scroll", Float)               = 0.0
		_UVCutScrollY                          	("├ Mask UV Y Scroll", FLoat)               = 0.0
		_CutStrength                            ("├ Mask Strength", Range(0.0, 10.0))       = 1.0
		[Toggle] _USEMASKPOS               		("└ Use Mask Posterize", Int)     			= 0
		_MaskPosterize                  		(" ╚ Posterize", Range(2, 50))       		= 2.0
		
		
		[Header(Distortion)]
		[Toggle] _USEDIST						("Use Distortion", Int)						= 0
		_DisTex                         		("└ Distortion Texture", 2D)             	= "white" {}
		
		[Header(Displacement)]
		_UVDisMap                       		("├ Displacement", Range(-1, 1)) 			= 0.0
		_DisMapScrollX                 			("├ U Speed",Float)                    		= 0.0
		_DisMapScrollY                  		("├ V Speed",FLoat)                    		= 0.0
		[Toggle] _DisToMask						("└ Apply Displacement to Mask",Int)		= 1
		
		[Header(Dissolve)]
		[Toggle] _USEDISSOLVE					("└ Use Dissolve", Int) 					= 0
		_DissolveAmount                    		(" ╠ Dissolve Amount", Range(0, 1))     	= 0.5
		_DissolveUSpeed                 		(" ╠ U Speed", Float)                		= 0
		_DissolveVSpeed                 		(" ╠ V Speed", Float)                		= 0
		[Toggle] _USEEDGE						(" ╚ Use Edge", Int)						= 0
		_Thickness                      		("  ╠ Thickness", Range(0.01, 1))           = 0
		[HDR]_FirstColor                     		("  ╠ Gradient Start", Color)           	= (0.5,0.5,0.5,1)
		[HDR]_SecondColor                    		("  ╚ Gradient End", Color)           		= (0.5,0.5,0.5,1)
		
		[Toggle] _USEDISSUV						(" ╚ Along UV", Int)						= 0
		[Enum(U,0,V,1)]_Axis					("  ╠ Axis", Int)							= 1
		[Toggle] _Reverse      					("  ╠ Reverse", Int)						= 0
		_DissolveStrength                		("  ╚ Noise Strength", Range(0, 1))			= 0.5


		[Header(Others)]
		[Toggle] _USESHEET                     	("Use Sheet Animation", Int)               	= 0
		_xx                                    	("├ Tiles X", float)                        = 1
		_yy                                    	("├ Tiles Y", float)                        = 1
		_Speed                                	("└ FPS", float)                            = 30
		[Toggle] _USEBLOOM						("Use Bloom", Int)							= 0
		_EmissionGain                   		("└ Brightness", Range(0, 1))            	= 0
	}
	SubShader
	{
		Tags { "Queue" = "Transparent" "RenderType" = "Transparent" "RenderPipeline" = "UniversalPipeline" "PreviewType"="Plane"}
		Blend [_BlendSrc] [_BlendDst]
		Cull [_Cull] 
		Lighting Off 
		ZWrite Off
		Pass
		{
			HLSLPROGRAM
				#pragma prefer_hlslcc gles
				#pragma exclude_renderers d3d11_9x
				#pragma vertex vert
				#pragma fragment frag
				#pragma multi_compile_fog
				#pragma multi_compile_instancing

				#pragma shader_feature Enable_UVRotation
				#pragma shader_feature Enable_UVScroll
				#pragma shader_feature Enable_UVMirror
				#pragma shader_feature Enable_Posterize

				#pragma shader_feature Enable_Rim
				
				#pragma shader_feature Enable_AlphaMask
				#pragma shader_feature Enable_Mask_Posterize
				
				#pragma shader_feature Enable_Distortion
				#pragma shader_feature Enable_Dissolve
				#pragma shader_feature Enable_Edge
				#pragma shader_feature Enable_UVDiss

				#pragma shader_feature Enable_Sheet
				#pragma shader_feature Enable_Bloom

				#include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
				
				TEXTURE2D(_BaseMap); SAMPLER(sampler_BaseMap);
				
				CBUFFER_START(UnityPerMaterial)
					half	  _BlendMode;
					half4 	  _BaseColor;
					float4    _BaseMap_ST;

					#ifdef Enable_UVScroll
						half _UVScrollX;
						half _UVScrollY;
						half _UVCutScrollX;
						half _UVCutScrollY;
					#endif

					#ifdef Enable_UVMirror
						half _UVMirrorX;
						half _UVMirrorY;	
					#endif

					#ifdef Enable_Rim
						half _RimRange;
						half _RimPower;
						half4 _RimColor;
					#endif

					#ifdef Enable_AlphaMask
						TEXTURE2D(_CutTex); SAMPLER(sampler_CutTex);
						float4    _CutTex_ST;
						half	_CutStrength;
					#endif

					#ifdef Enable_Distortion
						TEXTURE2D(_DisTex); SAMPLER(sampler_DisTex);
						float4 _DisTex_ST;
						half _UVDisMap;
						half _DisMapScrollX;
						half _DisMapScrollY;
						half _DisToMask;

						#ifdef Enable_Dissolve
							half _DissolveAmount;
							half _DissolveUSpeed;
							half _DissolveVSpeed;

							#ifdef Enable_Edge
								half _Thickness;
								half4 _FirstColor;
								half4 _SecondColor;
							#endif

							#ifdef Enable_UVDiss
								half _Axis;
								half _Reverse;
								half _DissolveStrength;
							#endif
						#endif
					#endif

					#ifdef Enable_UVRotation
						half _MainRotation;
						half _CutRotation;
					#endif

					#ifdef Enable_Bloom
						half _EmissionGain;
					#endif

					#ifdef Enable_Sheet
						half _xx;
						half _yy;
						half _Speed;
					#endif

					#ifdef Enable_Posterize
						half _Posterize;
					#endif

					#ifdef Enable_Mask_Posterize
						half _MaskPosterize;
					#endif
				CBUFFER_END

				struct appdata
				{
					float4 vertex : POSITION;
					float2 uv     : TEXCOORD0;
					float3 normal      : NORMAL;
					half4 color  : COLOR;
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				struct v2f
				{
					half4 vertex     : SV_POSITION;
					half4 color : COLOR;
					half2 uv_BaseMap : TEXCOORD0;
					float fogCoord   : TEXCOORD1;
					float3 posWorld   : TEXCOORD2;
					float3 normalDir  : TEXCOORD3;
					#ifdef Enable_AlphaMask
						float2 uv_CutOut  : TEXCOORD4;
					#endif
					#ifdef Enable_Distortion
						float2 uv_DistTex : TEXCOORD5;
						#ifdef Enable_Dissolve
							float2 uv_DissTex    : TEXCOORD6;
							float2 uv	:TEXCOORD7;
						#endif
					#endif	
					UNITY_VERTEX_INPUT_INSTANCE_ID
				};

				float invLerp(float from, float to, float value){
  					return (value - from) / (to - from);
				}
				
				v2f vert (appdata v)
				{
					v2f o = (v2f)0;
					UNITY_SETUP_INSTANCE_ID(v);
					UNITY_TRANSFER_INSTANCE_ID(v, o);
					VertexPositionInputs vertexInput = GetVertexPositionInputs(v.vertex.xyz);
					o.vertex = vertexInput.positionCS;
					#ifdef Enable_Rim
						o.posWorld = vertexInput.positionWS;
						o.normalDir = normalize(mul((float3x3)unity_ObjectToWorld, v.normal.xyz));
					#endif
					o.color = v.color;
					
					#ifdef Enable_Sheet
						float row = floor(_Time.y * _Speed);
						v.uv *= half2(1 / _xx, 1 / _yy);
						v.uv += half2(frac(row / _xx), floor(row / _xx) / _yy);
					#endif
					
					o.uv_BaseMap = TRANSFORM_TEX(v.uv, _BaseMap);
					
					#ifdef Enable_UVMirror
						half2 len = {_UVMirrorX, _UVMirrorY};
						o.uv_BaseMap = abs(o.uv_BaseMap - len);
					#endif

					#ifdef Enable_UVScroll
						float2 scroll = float2(_UVScrollX, _UVScrollY) * _Time.y * _BaseMap_ST.xy;
						o.uv_BaseMap += scroll;
					#endif

					#ifdef Enable_UVRotation
						o.uv_BaseMap.xy -= (0.5 * _BaseMap_ST.xy + _BaseMap_ST.zw);
						float sine = sin(radians(_MainRotation));
						float cosine = cos(radians(_MainRotation));
						float2x2 rotationMatrix = float2x2(cosine, -sine, sine, cosine);
						o.uv_BaseMap = mul(o.uv_BaseMap, rotationMatrix);
						o.uv_BaseMap += (0.5 * _BaseMap_ST.xy + _BaseMap_ST.zw);
					#endif

					#ifdef Enable_AlphaMask
						o.uv_CutOut =  TRANSFORM_TEX(v.uv, _CutTex);
						#ifdef Enable_UVScroll
							scroll = float2(_UVCutScrollX, _UVCutScrollY) * _Time.y * _CutTex_ST.xy;
							o.uv_CutOut += scroll;
						#endif
						#ifdef Enable_UVRotation
							o.uv_CutOut -= (0.5 * _CutTex_ST.xy + _CutTex_ST.zw);
							sine = sin(radians(_CutRotation));
							cosine = cos(radians(_CutRotation));
							rotationMatrix = float2x2(cosine, -sine, sine, cosine);
							o.uv_CutOut = mul(o.uv_CutOut, rotationMatrix);
							o.uv_CutOut += (0.5 * _CutTex_ST.xy + _CutTex_ST.zw);
						#endif
					#endif

					#ifdef Enable_Distortion
						o.uv_DistTex = TRANSFORM_TEX(v.uv, _DisTex);
						float2 move;
						move = float2(_DisMapScrollX, _DisMapScrollY) * _Time.y * _DisTex_ST.xy;
						o.uv_DistTex += move;
						#ifdef Enable_Dissolve
							o.uv_DissTex = o.uv_DistTex;
							move = float2(_DissolveUSpeed, _DissolveVSpeed) * _Time.y * _DisTex_ST.xy;
							o.uv_DissTex += move;
							o.uv = v.uv;
						#endif
					#endif
					o.fogCoord = ComputeFogFactor(o.vertex.z);
					return o;
				}

				half4 frag(v2f i) : SV_Target
				{
					UNITY_SETUP_INSTANCE_ID(i);
					half4 c = half4(0, 0, 0, 0);

					#ifdef Enable_Distortion
						half2 distort = SAMPLE_TEXTURE2D(_DisTex, sampler_DisTex, i.uv_DistTex).rg;
						#ifdef Enable_Dissolve
							half dissolve = SAMPLE_TEXTURE2D(_DisTex, sampler_DisTex, i.uv_DissTex + distort * _UVDisMap).a;
						#endif
						c = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv_BaseMap + distort * _UVDisMap);
						c *= _BaseColor * i.color;
												
						#ifdef Enable_Rim
							half3 viewDirection = normalize(GetCameraPositionWS() - i.posWorld.xyz);
							half3 normalDirection = normalize(i.normalDir);
							c.rgb = lerp(c.rgb, _RimColor.rgb, saturate(_RimPower * pow(saturate(1 - abs(dot(normalDirection, viewDirection))), 1/_RimRange)));
						#endif

						#ifdef Enable_Posterize
							c = saturate(floor((c)* _Posterize) / (_Posterize - 1));
						#endif

						#ifdef Enable_Dissolve
							#ifdef Enable_UVDiss
								half axis = (_Axis * i.uv.g + (1-_Axis) * i.uv.r);
								dissolve = saturate((1-_Reverse) * (1 - axis) + _Reverse * axis + dissolve * _DissolveStrength) - 0.01;
							#endif

							half d = step(_DissolveAmount, dissolve);
							#ifdef Enable_Edge
								half edge = d - step(saturate(_DissolveAmount + min(_DissolveAmount, _Thickness)), dissolve);
								half d2 = (dissolve - _DissolveAmount) / min(1 - _DissolveAmount + 0.001, _Thickness);
								half4 edgeCol = lerp(_FirstColor, _SecondColor, d2);
								c = lerp(c, edgeCol, edge);
							#endif
							c.a *= d;
						#endif
					#else
						c = SAMPLE_TEXTURE2D(_BaseMap, sampler_BaseMap, i.uv_BaseMap);
						c *= _BaseColor * i.color;

						#ifdef Enable_Rim
							half3 viewDirection = normalize(GetCameraPositionWS() - i.posWorld.xyz);
							half3 normalDirection = normalize(i.normalDir);
							c.rgb = lerp(c.rgb, _RimColor.rgb, saturate(_RimPower * pow(saturate(1 - abs(dot(normalDirection, viewDirection))), 1/_RimRange)));
						#endif

						#ifdef Enable_Posterize
							c = saturate(floor((c)* _Posterize) / (_Posterize - 1));
						#endif
					#endif
					
					#ifdef Enable_AlphaMask 
						#ifdef Enable_Mask_Posterize
							#ifdef Enable_Distortion
								c.a = saturate(lerp(c.a, c.a * saturate(floor(((SAMPLE_TEXTURE2D(_CutTex, sampler_CutTex, i.uv_CutOut + _DisToMask * distort * _UVDisMap).r))* _MaskPosterize) / (_MaskPosterize - 1)), _CutStrength));
							#else
								c.a = saturate(lerp(c.a, c.a * saturate(floor(((SAMPLE_TEXTURE2D(_CutTex, sampler_CutTex, i.uv_CutOut).r))* _MaskPosterize) / (_MaskPosterize - 1)), _CutStrength));
							#endif
						#else
							#ifdef Enable_Distortion
								c.a = saturate(lerp(c.a, c.a * SAMPLE_TEXTURE2D(_CutTex, sampler_CutTex, i.uv_CutOut + _DisToMask * distort * _UVDisMap).r, _CutStrength));
							#else
								c.a = saturate(lerp(c.a, c.a * SAMPLE_TEXTURE2D(_CutTex, sampler_CutTex, i.uv_CutOut).r, _CutStrength));
							#endif
						#endif
					#endif
				
					#ifdef Enable_Bloom
						c = half4(c.rgb *  (exp(_EmissionGain * 5.0f)), c.a);
					#endif
					
					c *= step(_BlendMode, 2) * c.a + (1 - step(_BlendMode, 2));

					c.rgb = MixFog(c.rgb, i.fogCoord);
					
					return c;
				}
			ENDHLSL
		}
	}  
	FallBack "Hidden/Universal Render Pipeline/FallbackError"
	CustomEditor "VfxGUI"
}