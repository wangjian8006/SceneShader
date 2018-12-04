#ifndef _AFT_CG_SCENELIGHTMODE_
#define _AFT_CG_SCENELIGHTMODE_

#include "../Shaders/CGInclude/AFT_CG_SceneInput.cginc"

half DotClamped (half3 a, half3 b)
{
    #if (SHADER_TARGET < 30)
        return saturate(dot(a, b));
    #else
        return max(0.0h, dot(a, b));
    #endif
}

half3 SafeNormalize(half3 inVec)
{
    half dp3 = max(0.001f, dot(inVec, inVec));
    return inVec * rsqrt(dp3);
}

#ifndef _AFT_SCENE_PBR
void AFT_Scene_HalfLambert(AFT_Scene_SetupData s,
					AFT_Scene_VertexCommonOutput i,
					out fixed4 color)
{
	fixed3 L = s.light.dir;

	//hLambert
	half hLambert = 1;
#if _AFT_SCENE_NORMAL || LIGHTMAP_OFF
	half nl = DotClamped(s.normal, L);
	hLambert = saturate(nl) * (1 - _HalfLambert) + _HalfLambert; 
#endif

	color.rgb = s.albedo.rgb * hLambert;
#if LIGHTMAP_ON
	color.rgb *= s.lightMap;
#endif

	//specular
	half specular = 1;
#if _AFT_SCENE_NORMAL
	half3 H = SafeNormalize(L + s.viewDir);

	half specularAngle = DotClamped(H, s.normal);		//半角向量与法线向量的夹角为高光角度
	specular = pow(specularAngle, _SpecularSharp) * _SpecularIntensity;

	#if _AFT_LUMINANCE_MASK_ON && LIGHTMAP_ON
		color.rgb += s.light.color * specular * s.gloss * s.lumin;
	#else
		color.rgb += s.light.color * specular * s.gloss;
	#endif

#endif

//color.rgb = half3(s.normal.r, s.normal.g, s.normal.b);
//color.rgb = half3(dot(s.normal, L), dot(s.normal, L), dot(s.normal, L));
//color.rgb = half3(hLambert, hLambert, hLambert);
}

#else

half SpecularStrength(half3 specular)
{
    #if (SHADER_TARGET < 30)
        // SM2.0: instruction count limitation
        // SM2.0: simplified SpecularStrength
        return specular.r; // Red channel - because most metals are either monocrhome or with redish/yellowish tint
    #else
        return max (max (specular.r, specular.g), specular.b);
    #endif
}

half3 EnergyConservationBetweenDiffuseAndSpecular (half3 albedo, half3 specColor, out half oneMinusReflectivity)
{
    oneMinusReflectivity = 1 - SpecularStrength(specColor);
    #if !UNITY_CONSERVE_ENERGY
        return albedo;
    #elif UNITY_CONSERVE_ENERGY_MONOCHROME
        return albedo * oneMinusReflectivity;
    #else
        return albedo * (half3(1,1,1) - specColor);
    #endif
}

half SmithVisibilityTerm (half NdotL, half NdotV, half k)
{
    half gL = NdotL * (1-k) + k;
    half gV = NdotV * (1-k) + k;
    return 1.0 / (gL * gV + 1e-5f);
}

half SmithBeckmannVisibilityTerm (half NdotL, half NdotV, half roughness)
{
    half c = 0.797884560802865h; // c = sqrt(2 / Pi)
    half k = roughness * c;
    return SmithVisibilityTerm (NdotL, NdotV, k) * 0.25f; // * 0.25 is the 1/4 of the visibility term
}

half NDFBlinnPhongNormalizedTerm (half NdotH, half n)
{
    // norm = (n+2)/(2*pi)
    half normTerm = (n + 2.0) * (0.5/UNITY_PI);

    half specTerm = pow (NdotH, n);
    return specTerm * normTerm;
}

half Pow4 (half x)
{
	half xx = x * x;
    return xx*xx;
}

half3 FresnelLerpFast (half3 F0, half3 F90, half cosA)
{
    half t = Pow4 (1 - cosA);
    return lerp (F0, F90, t);
}

half RoughnessToSpecPower (half perceptualRoughness)
{
    half m = perceptualRoughness * perceptualRoughness;
    half sq = max(1e-4f, m * m);
    half n = (2.0 / sq) - 2.0;
    n = max(n, 1e-4f);
    return n;
}

half OneMinusReflectivityFromMetallic(half metallic)
{
    half oneMinusDielectricSpec = unity_ColorSpaceDielectricSpec.a;
    return oneMinusDielectricSpec - metallic * oneMinusDielectricSpec;
}

half3 DiffuseAndSpecularFromMetallic (half3 albedo, half metallic, out half3 specColor, out half oneMinusReflectivity)
{
	specColor = lerp (unity_ColorSpaceDielectricSpec.rgb, albedo, metallic);
	oneMinusReflectivity = OneMinusReflectivityFromMetallic(metallic);
	return albedo * oneMinusReflectivity;
}

void AFT_Scene_PBR(AFT_Scene_SetupData s,
					AFT_Scene_VertexCommonOutput i,
					out fixed4 color)
{
	fixed3 L = s.light.dir;

#if LIGHTMAP_ON
	color.rgb *= s.lightMap;
#endif

#if _AFT_SCENE_NORMAL
		half oneMinusRoughness = 1 - s.roughness;
		half specularPower = RoughnessToSpecPower(s.roughness);

		//specular workflow
		//fixed oneMinusReflectivity;
		//fixed3 specColor = s.gloss * s.albedo.rgb;// * _SpecularColor.rgb * _SpecularIntensity; // monochrome specular -> color specular
		//fixed3 diffColor = EnergyConservationBetweenDiffuseAndSpecular(s.albedo.rgb, specColor, /*out*/ oneMinusReflectivity);

		// metallic workflow
		fixed metallic = s.gloss;	
		fixed3 specColor;
		fixed oneMinusReflectivity;		
		fixed3 diffColor = DiffuseAndSpecularFromMetallic(s.albedo.rgb, metallic, /*out*/ specColor, /*out*/ oneMinusReflectivity);
		
		fixed reflectivity = 1 - oneMinusReflectivity;
		half nv = DotClamped(s.normal, s.viewDir);	//视角向量与法线向量夹角
		half3 H = SafeNormalize(L + s.viewDir);		//半角向量

		half nl = DotClamped(s.normal, L);					//法线与灯光角度
		half nh = DotClamped(s.normal, H);		//半角向量与法线向量的夹角为高光角度
		//half lv = DotClamped(L, s.viewDir);		//灯光向量与视角向量夹角
		half lh = DotClamped(L, H);		//灯光向量与半角向量夹角
/*
		//UNITY_PBR
		//遮挡函数
		half V = SmithBeckmannVisibilityTerm (nl, nv, s.roughness);
		//法线分布函数 1/Pi
		half D = NDFBlinnPhongNormalizedTerm (nh, RoughnessToSpecPower(s.roughness));
		half specular = V * D * UNITY_PI;
*/
		half invV = lh * lh * oneMinusRoughness + s.roughness * s.roughness; 
		half invF = lh;
		half specular = ((specularPower + 1) * pow (nh, specularPower)) / (8 * invV * invF + 1e-4h);

		#ifdef UNITY_COLORSPACE_GAMMA
			specular = sqrt(max(1e-4h, specular));
		#endif

		//specular = clamp(specular, 0.0, 100.0); // Prevent FP16 overflow on mobile
		color.rgb += _GlobalAmbientColor * diffColor + (diffColor + specular * specColor) * s.light.color * nl;

		#if _AFT_SCENE_REFECTION
			half3 reflUVW = normalize(reflect(-s.viewDir, s.normal));
			fixed3 envColor = texCUBE(_RefectionTex, reflUVW) * _RefectionColor.rgb;

			half realRoughness = s.roughness * s.roughness;
			#ifdef UNITY_COLORSPACE_GAMMA
				half surfaceReduction = 0.28;
			#else
				half surfaceReduction = (0.6 - 0.08 * s.roughness);
			#endif

			surfaceReduction = 1.0 - realRoughness * s.roughness * surfaceReduction;	
								
			half grazingTerm = saturate(oneMinusRoughness + reflectivity);	
			color.rgb += surfaceReduction * envColor * FresnelLerpFast(specColor, grazingTerm, nv);
		#endif
#endif
}
#endif

fixed3 CalculatePointLight(AFT_Scene_SetupData s, AFT_Scene_VertexCommonOutput i, fixed3 color)
{
#if _AFT_SCENE_POINT_LIGHT
	half3 L = _GlobalPointLightPos.xyz - i.posWorld;
	half ratio = saturate(length(L) / _GlobalPointLightRange);
	//half attenuation = 1 - ratio; // linear attenuation
	ratio *= ratio;
	half attenuation = 1.0 / (1.0 + 0.01 * ratio) * (1 - ratio); // quadratic attenuation
	if (attenuation > 0) // performance
	{
		//diffuse
		L = normalize(L);
		half nl = max(0, dot(s.normal, L));
		color.rgb += s.albedo.rgb * _GlobalPointLightColor.rgb * nl * attenuation;

		//specular
	#if _AFT_SCENE_NORMAL
		half H = normalize(L + s.viewDir);
		half specularAngle = saturate(dot(s.normal, H));
		half specular = pow(specularAngle, _GlobalPointLightSpecularSharp);
		color.rgb += _GlobalPointLightColor.rgb * specular * attenuation;
	#endif
	}
#endif
	return color;
}

#endif