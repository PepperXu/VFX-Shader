using System.Collections.Generic;
using UnityEngine;
using UnityEditor;
using System.Collections;

public class VfxGUI : ShaderGUI
{
	public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] properties)
	{

		bool bEnableUVRotation = false;
		bool bEnableUVScroll   = false;
		bool bEnableUVMirror   = false;
		bool bEnablePosterize  = false;
		bool bEnableRim		   = false;
		bool bEnableAlphaMask  = false;
		bool bEnableMaskPost   = false;
		bool bEnableDistortion = false;
		bool bEnableDissolve   = false;
		bool bEnableEdge       = false;
		bool bEnableDissUV     = false;
		bool bEnableSheet      = false;
		bool bEnableBloom      = false;

		Material targetMat = materialEditor.target as Material;
		
		//Render Mode
		MaterialProperty _BlendMode		= ShaderGUI.FindProperty("_BlendMode", properties);
		materialEditor.ShaderProperty(_BlendMode, _BlendMode.displayName);
		MaterialProperty _Cull		= ShaderGUI.FindProperty("_Cull", properties);
		materialEditor.ShaderProperty(_Cull, _Cull.displayName);

		switch(_BlendMode.floatValue){
			case 0: targetMat.SetInt("_BlendSrc", 1); targetMat.SetInt("_BlendDst", 1); break;
			case 1: targetMat.SetInt("_BlendSrc", 1); targetMat.SetInt("_BlendDst", 10); break;
			case 2: targetMat.SetInt("_BlendSrc", 5); targetMat.SetInt("_BlendDst", 10); break;
			default: Debug.LogError("Blend Mode does not exist!"); targetMat.SetInt("_BlendSrc", 1); targetMat.SetInt("_BlendDst", 1); break;
		}

		//Primary Properties and Toggles

		MaterialProperty _BaseColor		= ShaderGUI.FindProperty("_BaseColor", properties);
		MaterialProperty _BaseMap		= ShaderGUI.FindProperty("_BaseMap", properties);
		MaterialProperty _MainRotation 	= ShaderGUI.FindProperty("_MainRotation", properties);
		MaterialProperty _UVScrollX 	= ShaderGUI.FindProperty("_UVScrollX", properties);
		MaterialProperty _UVScrollY 	= ShaderGUI.FindProperty("_UVScrollY", properties);
		MaterialProperty _USEPOS 		= ShaderGUI.FindProperty("_USEPOS", properties);
		MaterialProperty _USEMIRROR 	= ShaderGUI.FindProperty("_USEMIRROR", properties);
		MaterialProperty _USERIM 		= ShaderGUI.FindProperty("_USERIM", properties);
		MaterialProperty _USEMASK 		= ShaderGUI.FindProperty("_USEMASK", properties);
		MaterialProperty _USEDIST 		= ShaderGUI.FindProperty("_USEDIST", properties);
		MaterialProperty _USESHEET 		= ShaderGUI.FindProperty("_USESHEET", properties);
		MaterialProperty _USEBLOOM 		= ShaderGUI.FindProperty("_USEBLOOM", properties);

		materialEditor.ShaderProperty(_BaseColor, _BaseColor.displayName);
		materialEditor.ShaderProperty(_BaseMap, _BaseMap.displayName);
		materialEditor.ShaderProperty(_MainRotation, _MainRotation.displayName);
		materialEditor.ShaderProperty(_UVScrollX, _UVScrollX.displayName);
		materialEditor.ShaderProperty(_UVScrollY, _UVScrollY.displayName);
		
			
		if (_MainRotation.floatValue != 0.0f)
		{
			bEnableUVRotation = true;
		}

		if(_UVScrollX.floatValue != 0.0f || _UVScrollY.floatValue != 0.0f)
		{
			bEnableUVScroll = true;
		}

		materialEditor.ShaderProperty(_USEPOS, _USEPOS.displayName);

		if(_USEPOS.floatValue == 1){
			bEnablePosterize = true;
			MaterialProperty _Posterize = ShaderGUI.FindProperty("_Posterize", properties);
			materialEditor.ShaderProperty(_Posterize, _Posterize.displayName);
		}

		materialEditor.ShaderProperty(_USEMIRROR, _USEMIRROR.displayName);

		if(_USEMIRROR.floatValue == 1){
			bEnableUVMirror = true;
			MaterialProperty _UVMirrorX = ShaderGUI.FindProperty("_UVMirrorX", properties);
			materialEditor.ShaderProperty(_UVMirrorX, _UVMirrorX.displayName);
			MaterialProperty _UVMirrorY = ShaderGUI.FindProperty("_UVMirrorY", properties);
			materialEditor.ShaderProperty(_UVMirrorY, _UVMirrorY.displayName);
		}
		
		materialEditor.ShaderProperty(_USERIM, _USERIM.displayName);

		if(_USERIM.floatValue == 1){
			bEnableRim = true;
			MaterialProperty _RimRange = ShaderGUI.FindProperty("_RimRange", properties);
			materialEditor.ShaderProperty(_RimRange, _RimRange.displayName);
			MaterialProperty _RimPower = ShaderGUI.FindProperty("_RimPower", properties);
			materialEditor.ShaderProperty(_RimPower, _RimPower.displayName);
			MaterialProperty _RimColor = ShaderGUI.FindProperty("_RimColor", properties);
			materialEditor.ShaderProperty(_RimColor, _RimColor.displayName);
		}

		materialEditor.ShaderProperty(_USEMASK, _USEMASK.displayName);

		if(_USEMASK.floatValue == 1){
			bEnableAlphaMask = true;
			MaterialProperty _CutTex = ShaderGUI.FindProperty("_CutTex", properties);
			materialEditor.ShaderProperty(_CutTex, _CutTex.displayName);
			MaterialProperty _CutRotation = ShaderGUI.FindProperty("_CutRotation", properties);
			materialEditor.ShaderProperty(_CutRotation, _CutRotation.displayName);
			MaterialProperty _UVCutScrollX = ShaderGUI.FindProperty("_UVCutScrollX", properties);
			materialEditor.ShaderProperty(_UVCutScrollX, _UVCutScrollX.displayName);
			MaterialProperty _UVCutScrollY = ShaderGUI.FindProperty("_UVCutScrollY", properties);
			materialEditor.ShaderProperty(_UVCutScrollY, _UVCutScrollY.displayName);
			MaterialProperty _CutStrength = ShaderGUI.FindProperty("_CutStrength", properties);
			materialEditor.ShaderProperty(_CutStrength, _CutStrength.displayName);
			if(_CutRotation.floatValue != 0.0f){
				bEnableUVRotation = true;
			}
			if(_UVCutScrollX.floatValue != 0.0f || _UVCutScrollY.floatValue != 0.0f){
				bEnableUVScroll = true;
			}
			MaterialProperty _USEMASKPOS = ShaderGUI.FindProperty("_USEMASKPOS", properties);
			materialEditor.ShaderProperty(_USEMASKPOS, _USEMASKPOS.displayName);
			if(_USEMASKPOS.floatValue == 1){
				bEnableMaskPost = true;
				MaterialProperty _MaskPosterize = ShaderGUI.FindProperty("_MaskPosterize", properties);
				materialEditor.ShaderProperty(_MaskPosterize, _MaskPosterize.displayName);
			}
		}

		materialEditor.ShaderProperty(_USEDIST, _USEDIST.displayName);

		if(_USEDIST.floatValue == 1){
			bEnableDistortion = true;
			MaterialProperty _DisTex = ShaderGUI.FindProperty("_DisTex", properties);
			materialEditor.ShaderProperty(_DisTex, _DisTex.displayName);
			MaterialProperty _UVDisMap = ShaderGUI.FindProperty("_UVDisMap", properties);
			materialEditor.ShaderProperty(_UVDisMap, _UVDisMap.displayName);
			MaterialProperty _DisMapScrollX = ShaderGUI.FindProperty("_DisMapScrollX", properties);
			materialEditor.ShaderProperty(_DisMapScrollX, _DisMapScrollX.displayName);
			MaterialProperty _DisMapScrollY = ShaderGUI.FindProperty("_DisMapScrollY", properties);
			materialEditor.ShaderProperty(_DisMapScrollY, _DisMapScrollY.displayName);

			if(_USEMASK.floatValue == 1){
				MaterialProperty _DisToMask = ShaderGUI.FindProperty("_DisToMask", properties);
				materialEditor.ShaderProperty(_DisToMask, _DisToMask.displayName);
			} else {
				targetMat.SetInt("_DisToMask", 0);
			}

			MaterialProperty _USEDISSOLVE = ShaderGUI.FindProperty("_USEDISSOLVE", properties);
			materialEditor.ShaderProperty(_USEDISSOLVE, _USEDISSOLVE.displayName);

			if(_USEDISSOLVE.floatValue == 1){
				bEnableDissolve = true;
				MaterialProperty _DissolveAmount = ShaderGUI.FindProperty("_DissolveAmount", properties);
				materialEditor.ShaderProperty(_DissolveAmount, _DissolveAmount.displayName);
				MaterialProperty _DissolveUSpeed = ShaderGUI.FindProperty("_DissolveUSpeed", properties);
				materialEditor.ShaderProperty(_DissolveUSpeed, _DissolveUSpeed.displayName);
				MaterialProperty _DissolveVSpeed = ShaderGUI.FindProperty("_DissolveVSpeed", properties);
				materialEditor.ShaderProperty(_DissolveVSpeed, _DissolveVSpeed.displayName);
				
				MaterialProperty _USEEDGE = ShaderGUI.FindProperty("_USEEDGE", properties);
				materialEditor.ShaderProperty(_USEEDGE, _USEEDGE.displayName);
				
				if(_USEEDGE.floatValue == 1){
					bEnableEdge = true;
					MaterialProperty _Thickness = ShaderGUI.FindProperty("_Thickness", properties);
					materialEditor.ShaderProperty(_Thickness, _Thickness.displayName);
					MaterialProperty _FirstColor = ShaderGUI.FindProperty("_FirstColor", properties);
					materialEditor.ShaderProperty(_FirstColor, _FirstColor.displayName);
					MaterialProperty _SecondColor = ShaderGUI.FindProperty("_SecondColor", properties);
					materialEditor.ShaderProperty(_SecondColor, _SecondColor.displayName);
				}
				
				MaterialProperty _USEDISSUV = ShaderGUI.FindProperty("_USEDISSUV", properties);
				materialEditor.ShaderProperty(_USEDISSUV, _USEDISSUV.displayName);

				if(_USEDISSUV.floatValue == 1){
					bEnableDissUV = true;
					MaterialProperty _Axis = ShaderGUI.FindProperty("_Axis", properties);
					materialEditor.ShaderProperty(_Axis, _Axis.displayName);
					MaterialProperty _Reverse = ShaderGUI.FindProperty("_Reverse", properties);
					materialEditor.ShaderProperty(_Reverse, _Reverse.displayName);
					MaterialProperty _DissolveStrength = ShaderGUI.FindProperty("_DissolveStrength", properties);
					materialEditor.ShaderProperty(_DissolveStrength, _DissolveStrength.displayName);
				}
			}
		}

		materialEditor.ShaderProperty(_USESHEET, _USESHEET.displayName);

		if(_USESHEET.floatValue == 1){
			bEnableSheet = true;
			MaterialProperty _xx = ShaderGUI.FindProperty("_xx", properties);
			materialEditor.ShaderProperty(_xx, _xx.displayName);
			MaterialProperty _yy = ShaderGUI.FindProperty("_yy", properties);
			materialEditor.ShaderProperty(_yy, _yy.displayName);
			MaterialProperty _Speed = ShaderGUI.FindProperty("_Speed", properties);
			materialEditor.ShaderProperty(_Speed, _Speed.displayName);
		}

		materialEditor.ShaderProperty(_USEBLOOM, _USEBLOOM.displayName);
		
		if(_USEBLOOM.floatValue == 1){
			bEnableBloom = true;
			MaterialProperty _EmissionGain = ShaderGUI.FindProperty("_EmissionGain", properties);
			materialEditor.ShaderProperty(_EmissionGain, _EmissionGain.displayName);
		}
		
		materialEditor.EnableInstancingField();

		if (bEnableUVRotation) targetMat.EnableKeyword ("Enable_UVRotation");
		else               targetMat.DisableKeyword("Enable_UVRotation");
		if (bEnableUVScroll) targetMat.EnableKeyword("Enable_UVScroll");
		else               targetMat.DisableKeyword("Enable_UVScroll");
		if (bEnableUVMirror) targetMat.EnableKeyword("Enable_UVMirror");
		else                   targetMat.DisableKeyword("Enable_UVMirror");
		if (bEnablePosterize) targetMat.EnableKeyword("Enable_Posterize");
		else                 targetMat.DisableKeyword("Enable_Posterize");
		if (bEnableRim) targetMat.EnableKeyword("Enable_Rim");
		else                 targetMat.DisableKeyword("Enable_Rim");
		if (bEnableAlphaMask) targetMat.EnableKeyword("Enable_AlphaMask");         
		else                 targetMat.DisableKeyword("Enable_AlphaMask");
		if (bEnableMaskPost) targetMat.EnableKeyword ("Enable_Mask_Posterize");
		else              targetMat.DisableKeyword("Enable_Mask_Posterize");
		if (bEnableDistortion) targetMat.EnableKeyword ("Enable_Distortion");
		else           targetMat.DisableKeyword("Enable_Distortion");		
		if (bEnableDissolve) targetMat.EnableKeyword ("Enable_Dissolve");
		else           targetMat.DisableKeyword("Enable_Dissolve");
		if (bEnableEdge) targetMat.EnableKeyword ("Enable_Edge");
		else           targetMat.DisableKeyword("Enable_Edge");
		if (bEnableDissUV) targetMat.EnableKeyword ("Enable_UVDiss");
		else           targetMat.DisableKeyword("Enable_UVDiss");
		if (bEnableSheet) targetMat.EnableKeyword ("Enable_Sheet");
		else           targetMat.DisableKeyword("Enable_Sheet");
		if (bEnableBloom) targetMat.EnableKeyword ("Enable_Bloom");
		else           targetMat.DisableKeyword("Enable_Bloom");
	}
}
