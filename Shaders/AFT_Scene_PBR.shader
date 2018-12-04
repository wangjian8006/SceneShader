Shader "AFTShader/Scene/PBR"
{
	Properties
	{
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_MainTex("Main Texture RGB(Albedo) A(Gloss & Alpha)", 2D) = "white" {}
		_NormalTex("Normal Texture", 2D) = "bump" {}
		_GlossTex ("Gloss Texture", 2D) = "white" {}		//r:金属度，g:粗糙度

		_Roughness("Roughness",Range (-1, 5)) = 0			//粗糙度
		_GlossMapScale("Smoothness", Range(0.0, 10.0)) = 1.0
		 
		_RefectionTex("Refection Texture (Cubemap)", Cube) = "" {}
		_RefectionColor ("Refection Color", Color) = (1, 1, 1, 1)
	} 
	SubShader
	{
		Tags
		{
			"Queue" = "Background" 		
			"RenderType" = "Opaque" // 支持渲染到_CameraDepthNormalsTexture   
		}

		Pass
		{
			Lighting Off
			CGPROGRAM

			#define _AFT_SCENE_PBR

			#pragma multi_compile_fog
			#pragma fragmentoption ARB_precision_hint_fastest		//低精度提升效率       

			#pragma shader_feature _AFT_SCENE_NORMAL
			#pragma shader_feature _AFT_SCENE_REFECTION
			#pragma shader_feature _AFT_SCENE_ROUGHNESS_TEX
			#pragma shader_feature _AFT_SCENE_DEBUG
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			//全局开关，点光源
			#pragma multi_compile __ _AFT_SCENE_POINT_LIGHT

			fixed _Roughness;
			fixed4 _Color;  
			uniform sampler2D _MainTex;half4 _MainTex_ST;

			fixed3 _GlobalAmbientColor;
			fixed3 _GlobalDirectionLightDir;
			fixed4 _GlobalDirectionLightColor;
 
#if _AFT_SCENE_POINT_LIGHT
			float4 _GlobalPointLightPos;
			fixed4 _GlobalPointLightColor;
			fixed _GlobalPointLightRange;
			fixed _GlobalPointLightSpecularSharp;
#endif

			fixed4 _LightColor0;
			fixed _GlossMapScale;

#if _AFT_SCENE_NORMAL
			sampler2D _GlossTex;
			uniform sampler2D _NormalTex;half4 _NormalTex_ST;
			#if _AFT_SCENE_REFECTION
				samplerCUBE  _RefectionTex; 
				fixed4 _RefectionColor;
			#endif
#endif

			#include "../Shaders/CGInclude/AFT_CG_SceneCommon.cginc" 
			#pragma vertex aft_common_vertext
			#pragma fragment frag2

			fixed4 frag2(AFT_Scene_VertexCommonOutput i) : COLOR
			{
				AFT_Scene_SetupData s = SceneSetup(i);  
				fixed4 finalColor = fixed4(1, 1, 1, 1); 
				AFT_Scene_PBR(s, i, finalColor);
				finalColor.rgb = CalculatePointLight(s, i, finalColor); 

				UNITY_APPLY_FOG(i.fogCoord, finalColor);

				return finalColor;
			}
			ENDCG
		}
	}
	CustomEditor "AFT_Scene_PBR_Shader_GUI"
}