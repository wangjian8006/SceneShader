using System;
using UnityEngine;
using UnityEditor;

public class AFT_Scene_Standard_Shader_GUI : ShaderGUI
{
    MaterialEditor m_MaterialEditor;
    bool m_FirstTimeApply = true;

    MaterialProperty _Color;

    MaterialProperty _MainTex;
    MaterialProperty _NormalTex;
    MaterialProperty _GlossTex;

    MaterialProperty _HalfLambert;

    MaterialProperty _SpecularIntensity;
    MaterialProperty _SpecularSharp;

    public void FindProperties(MaterialProperty[] props)
    {
        _Color = FindProperty("_Color", props);

        _MainTex = FindProperty("_MainTex", props);
        _NormalTex = FindProperty("_NormalTex", props);
        _GlossTex = FindProperty("_GlossTex", props);

        _HalfLambert = FindProperty("_HalfLambert", props);
        _SpecularSharp = FindProperty("_SpecularSharp", props);
        _SpecularIntensity = FindProperty("_SpecularIntensity", props);
    }

    static void MaterialChanged(Material material)
    {
        SetMaterialKeywords(material);
    }

    static void SetMaterialKeywords(Material material)
    {
        SetKeyword(material, "_AFT_SCENE_NORMAL", material.GetTexture("_NormalTex"));
        //SetKeyword(material, "_AFT_SCENE_GLOSS", material.GetTexture("_GlossTex"));
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
            m_MaterialEditor.DefaultShaderProperty(_HalfLambert, _HalfLambert.displayName);
            m_MaterialEditor.DefaultShaderProperty(_SpecularSharp, _SpecularSharp.displayName);
            m_MaterialEditor.DefaultShaderProperty(_SpecularIntensity, _SpecularIntensity.displayName);
        }
        if (EditorGUI.EndChangeCheck())
        {
            MaterialChanged(material);
        }
    }
}
