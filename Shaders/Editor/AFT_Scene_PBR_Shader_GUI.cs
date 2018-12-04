using System;
using UnityEngine;
using UnityEditor;

public class AFT_Scene_PBR_Shader_GUI : ShaderGUI
{
    MaterialEditor m_MaterialEditor;
    bool m_FirstTimeApply = true;

    MaterialProperty _Color;

    MaterialProperty _MainTex;
    MaterialProperty _NormalTex;
    MaterialProperty _GlossTex;

    MaterialProperty _Roughness;
    MaterialProperty _GlossMapScale;

    MaterialProperty _RefectionTex;
    MaterialProperty _RefectionColor;

    public void FindProperties(MaterialProperty[] props)
    {
        _Color = FindProperty("_Color", props);

        _MainTex = FindProperty("_MainTex", props);
        _NormalTex = FindProperty("_NormalTex", props);
        _GlossTex = FindProperty("_GlossTex", props);

        _Roughness = FindProperty("_Roughness", props);
        _GlossMapScale = FindProperty("_GlossMapScale", props);

        _RefectionTex = FindProperty("_RefectionTex", props);
        _RefectionColor = FindProperty("_RefectionColor", props);
    }

    static void MaterialChanged(Material material)
    {
        SetMaterialKeywords(material);
    }

    static void SetMaterialKeywords(Material material)
    {
        SetKeyword(material, "_AFT_SCENE_NORMAL", material.GetTexture("_NormalTex"));
        SetKeyword(material, "_AFT_SCENE_REFECTION", material.GetTexture("_RefectionTex"));
        SetKeyword(material, "_AFT_SCENE_ROUGHNESS_TEX", material.GetFloat("_Roughness") <= 0);
    }

    static void SetKeyword(Material m, string keyword, bool state)
    {
        if (state)
            m.EnableKeyword(keyword);
        else
            m.DisableKeyword(keyword);
    }

    public override void OnGUI(MaterialEditor materialEditor, MaterialProperty[] props)
    {
        FindProperties(props);
        m_MaterialEditor = materialEditor;
        Material material = materialEditor.target as Material;

        if (m_FirstTimeApply)
        {
            MaterialChanged(material);
            m_FirstTimeApply = false;
        }

        ShaderPropertiesGUI(material);
    }

    public void ShaderPropertiesGUI(Material material)
    {
        EditorGUIUtility.labelWidth = 0f;

        EditorGUI.BeginChangeCheck();
        {
            m_MaterialEditor.DefaultShaderProperty(_Color, _Color.displayName);
            m_MaterialEditor.DefaultShaderProperty(_MainTex, _MainTex.displayName);
            m_MaterialEditor.DefaultShaderProperty(_NormalTex, _NormalTex.displayName);
            m_MaterialEditor.DefaultShaderProperty(_GlossTex, _GlossTex.displayName);

            m_MaterialEditor.DefaultShaderProperty(_Roughness, _Roughness.displayName);
            m_MaterialEditor.DefaultShaderProperty(_GlossMapScale, _GlossMapScale.displayName);

            m_MaterialEditor.DefaultShaderProperty(_RefectionTex, _RefectionTex.displayName);
            m_MaterialEditor.DefaultShaderProperty(_RefectionColor, _RefectionColor.displayName);
        }
        if (EditorGUI.EndChangeCheck())
        {
            MaterialChanged(material);
        }
    }
}
