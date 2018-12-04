Shader "AFTShader/Scene/Standard" 
{
	Properties
	{
		_Color ("Main Color", Color) = (1, 1, 1, 1)
		_MainTex("Main Texture RGB(Albedo) A(Gloss & Alpha)", 2D) = "white" {}
		_NormalTex("Normal Texture", 2D) = "bump" {}
		_GlossTex ("Gloss Texture", 2D) = "white" {}
 
		_HalfLambert("Half Lambert", Range (0.5, 1)) = 0.75
 
		_SpecularIntensity("Specular Intensity", Range (0, 2)) = 0
		_SpecularSharp("Specular Sharp",Float) = 32
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

			#pragma multi_compile_fog
			#pragma fragmentoption ARB_precision_hint_fastest		//低精度提升效率 

			#pragma shader_feature _AFT_SCENE_NORMAL
			//#pragma shader_feature _AFT_LUMINANCE_MASK_ON			//
			#pragma shader_feature _AFT_SCENE_DEBUG
			#pragma multi_compile LIGHTMAP_OFF LIGHTMAP_ON

			//全局开关，点光源
			#pragma multi_compile __ _AFT_SCENE_POINT_LIGHT

			fixed4 _Color;  
			uniform sampler2D _MainTex;half4 _MainTex_ST;

			fixed3 _GlobalDirectionLightDir;
			fixed4 _GlobalDirectionLightColor;
 
#if _AFT_SCENE_POINT_LIGHT
			float4 _GlobalPointLightPos;
			fixed4 _GlobalPointLightColor;
			fixed _GlobalPointLightRange;
			fixed _GlobalPointLightSpecularSharp;
#endif

			fixed _HalfLambert;
			fixed _SpecularIntensity;
			fixed _SpecularSharp;
			fixed4 _LightColor0;

#if _AFT_LUMINANCE_MASK_ON
			fixed _SpecularLuminanceMask;
#endif

#if _AFT_SCENE_NORMAL
			sampler2D _GlossTex;
			uniform sampler2D _NormalTex;half4 _NormalTex_ST;
#endif

			#include "../Shaders/CGInclude/AFT_CG_SceneCommon.cginc"
			#pragma vertex aft_common_vertext
			#pragma fragment frag2

			fixed4 frag2(AFT_Scene_VertexCommonOutput i) : COLOR
			{
				AFT_Scene_SetupData s = SceneSetup(i);
				fixed4 finalColor = fixed4(1, 1, 1, 1); 
				AFT_Scene_HalfLambert(s, i, finalColor);
				finalColor.rgb = CalculatePointLight(s, i, finalColor); 

				UNITY_APPLY_FOG(i.fogCoord, finalColor);

				return finalColor;
			}
			ENDCG
		}
	}
	
	CustomEditor "AFT_Scene_Standard_Shader_GUI"
}