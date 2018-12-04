#ifndef _AFT_CG_SCENEINPUT_
#define _AFT_CG_SCENEINPUT_

struct AFT_Scene_VertexCommonInput 
{
	float4 vertex : POSITION;
	half2 texcoord : TEXCOORD0;
	half2 texcoord1 : TEXCOORD1;
	half3 normal : NORMAL;
#if _AFT_SCENE_NORMAL
	half4 tangent : TANGENT;
#endif 
};

struct AFT_Scene_VertexCommonOutput 
{
	float4 pos : SV_POSITION;
	half2 uv0 : TEXCOORD0;
#ifndef LIGHTMAP_OFF 
	half2 uv1 : TEXCOORD1;
#endif

	UNITY_FOG_COORDS(2)

	float3 posWorld : TEXCOORD3;
	half3 normalWorld : TEXCOORD4;

#if _AFT_SCENE_NORMAL
	half3 tangentWorld : TEXCOORD5;
	half3 binormalWorld : TEXCOORD6;
#endif
};

struct AFT_Light
{
	half3 color;
	half3 dir;
};

struct AFT_Scene_SetupData
{
	half4 albedo;
	half3 normal;

#ifndef LIGHTMAP_OFF
	half3 lightMap;
#endif

#if _AFT_LUMINANCE_MASK_ON
	half lumin;
#endif

	AFT_Light light;

#if _AFT_SCENE_NORMAL
	half gloss;
	half3 viewDir;
#endif
	
#ifdef _AFT_SCENE_PBR
	fixed roughness;
#endif
};

#endif