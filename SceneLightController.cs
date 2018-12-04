using System;
using System.Collections.Generic;
using UnityEngine;

public class SceneLightController : MonoBehaviour
{
    public Color GlobalAmbientColor = Color.grey;

    public Vector3 GlobalDirectionLightDir = Vector3.one;

    public Color GlobalDirectionLightColor = Color.grey;

    public bool bOpenPointLight = false;

    public float GlobalPointLightRange = 0;

    public Color GlobalPointLightColor = Color.grey;

	public float GlobalPointLightIntensity = 1.0f;

    public float GlobalPointLightSpecularSharp = 32;

    public float GlobalPointLightPositionYOffset = 1.0f;

    protected bool preOpenPointLight = true;

    void Start()
    {
        preOpenPointLight = !bOpenPointLight;
        CheckPointLight();
        Shader.EnableKeyword("_AFT_SCENE_DEBUG");
    }

    protected void CheckPointLight()
    {
        if (preOpenPointLight != bOpenPointLight)
        {
            if (bOpenPointLight == true) Shader.EnableKeyword("_AFT_SCENE_POINT_LIGHT");
            else Shader.DisableKeyword("_AFT_SCENE_POINT_LIGHT");
            preOpenPointLight = bOpenPointLight;
        }
    }

    void Update()
    {
        CheckPointLight();
        Shader.SetGlobalVector("_GlobalDirectionLightDir", GlobalDirectionLightDir);
        Shader.SetGlobalColor("_GlobalDirectionLightColor", GlobalDirectionLightColor);

        Vector3 pos = this.gameObject.transform.position;
        pos.y += GlobalPointLightPositionYOffset;
        Shader.SetGlobalVector("_GlobalPointLightPos", pos);
        Shader.SetGlobalFloat("_GlobalPointLightRange", GlobalPointLightRange);
        Shader.SetGlobalColor("_GlobalPointLightColor", GlobalPointLightColor * GlobalPointLightIntensity);
        Shader.SetGlobalFloat("_GlobalPointLightSpecularSharp", GlobalPointLightSpecularSharp);
        Shader.SetGlobalColor("_GlobalAmbientColor", GlobalAmbientColor);
    }

    void Destory()
    {
        Shader.DisableKeyword("_AFT_SCENE_DEBUG");
    }
}