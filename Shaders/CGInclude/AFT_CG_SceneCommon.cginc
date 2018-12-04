#ifndef _AFT_CG_SCENECOMMON_
#define _AFT_CG_SCENECOMMON_

#include "UnityCG.cginc"
#include "AutoLight.cginc"
#include "../Shaders/CGInclude/AFT_CG_SceneInput.cginc"
#include "../Shaders/CGInclude/AFT_CG_SceneLightMode.cginc"

AFT_Scene_VertexCommonOutput aft_common_vertext(AFT_Scene_VertexCommonInput i)
{
	AFT_Scene_VertexCommonOutput o;
	o.pos = UnityObjectToClipPos(i.vertex);
	o.uv0 = TRANSFORM_TEX(i.texcoord, _MainTex);

#ifndef LIGHTMAP_OFF
	o.uv1 = i.texcoord1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
#endif

	o.posWorld = mul(unity_ObjectToWorld, i.vertex).xyz;
	o.normalWorld = UnityObjectToWorldNormal(i.normal);

#if _AFT_SCENE_NORMAL
	o.tangentWorld = UnityObjectToWorldDir(i.tangent);
	o.binormalWorld = cross(o.normalWorld, o.tangentWorld) * i.tangent.w;
#endif

	UNITY_TRANSFER_FOG(o, o.pos);
	return o;
}

fixed3 CalculateNormal(AFT_Scene_VertexCommonOutput i)
{
#if _AFT_SCENE_NORMAL
	fixed3x3 tangentToWorld = fixed3x3(i.tangentWorld, i.binormalWorld, i.normalWorld);
	half3 normalMap = UnpackNormal(tex2D(_NormalTex, i.uv0));
	return normalize(mul(normalMap, tangentToWorld));
#else
	return normalize(i.normalWorld);
#endif
}

AFT_Light AFT_GetMainLight()
{
	AFT_Light l;
#ifndef _AFT_SCENE_DEBUG
	l.color = _LightColor0.rgb;
	l.dir = normalize(_WorldSpaceLightPos0.xyz);
#else
	l.color = _GlobalDirectionLightColor.rgb;
	l.dir = normalize(_GlobalDirectionLightDir.xyz);
#endif
	return l;
}

AFT_Scene_SetupData SceneSetup(AFT_Scene_VertexCommonOutput i)
{
	AFT_Scene_SetupData s;
	s.albedo = tex2D(_MainTex, i.uv0) * _Color;
#ifndef LIGHTMAP_OFF
	s.lightMap = DecodeLightmap(UNITY_SAMPLE_TEX2D(unity_Lightmap, i.uv1));
#endif

#if _AFT_LUMINANCE_MASK_ON
	s.lumin = saturate(Luminance(lm) * _SpecularLuminanceMask);
#endif

#if _AFT_SCENE_NORMAL
	fixed4 glossTex = tex2D(_GlossTex, i.uv0);
	s.gloss = glossTex.r;
	#ifdef _AFT_SCENE_PBR
		#if _AFT_SCENE_ROUGHNESS_TEX
			s.roughness = glossTex.g * _GlossMapScale;
		#else
			s.roughness = _Roughness * _GlossMapScale;
		#endif
	#endif
	s.viewDir = normalize(_WorldSpaceCameraPos - i.posWorld);
#endif
	
	s.normal = CalculateNormal(i);
	s.light = AFT_GetMainLight();

	return s;
}

#endif