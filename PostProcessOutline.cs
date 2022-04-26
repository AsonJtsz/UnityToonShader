using System;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

[Serializable]
[PostProcess(typeof(PostProcessOutlineRenderer), PostProcessEvent.BeforeStack, "Post Process Outline")]
public sealed class PostProcessOutline : PostProcessEffectSettings
{
    public IntParameter scale = new IntParameter { value = 1 };
    public ColorParameter color = new ColorParameter { value = Color.black };
    public FloatParameter depthThreshold = new FloatParameter { value = 1.5f };
    [Range(0, 1)] public FloatParameter depthNormalThreshold = new FloatParameter { value = 0.5f };
    public FloatParameter depthNormalThresholdScale = new FloatParameter { value = 7 };
    [Range(0, 1)] public FloatParameter normalThreshold = new FloatParameter { value = 0.4f };

    [Range(0.0005f, 0.0025f)] public FloatParameter delta = new FloatParameter { value = 0.0025f };

    public FloatParameter depthSobelThreshold = new FloatParameter { value = 0.1f };
    public FloatParameter depthEnable = new FloatParameter { value = 1.0f };

    public FloatParameter depthNormalEnable = new FloatParameter { value = 1.0f };

    public FloatParameter depthSobelEnable = new FloatParameter { value = 1.0f };

}

public sealed class PostProcessOutlineRenderer : PostProcessEffectRenderer<PostProcessOutline>
{
    public override void Render(PostProcessRenderContext context)
    {
        var sheet = context.propertySheets.Get(Shader.Find("Hidden/Outline Post Process"));
        sheet.properties.SetFloat("_Scale", settings.scale);
        sheet.properties.SetColor("_Color", settings.color);
        sheet.properties.SetFloat("_DepthThreshold", settings.depthThreshold);
        sheet.properties.SetFloat("_DepthNormalThreshold", settings.depthNormalThreshold);
        sheet.properties.SetFloat("_DepthNormalThresholdScale", settings.depthNormalThresholdScale);
        sheet.properties.SetFloat("_NormalThreshold", settings.normalThreshold);
        sheet.properties.SetColor("_Color", settings.color);
        sheet.properties.SetFloat("_Delta", settings.delta);
        sheet.properties.SetFloat("_DepthSobelThreshold", settings.depthSobelThreshold);
        sheet.properties.SetFloat("_depthEnable", settings.depthEnable);
        sheet.properties.SetFloat("_depthNormalEnable", settings.depthNormalEnable);
        sheet.properties.SetFloat("_depthSobelEnable", settings.depthSobelEnable);

        Matrix4x4 clipToView = GL.GetGPUProjectionMatrix(context.camera.projectionMatrix, true).inverse;
        sheet.properties.SetMatrix("_ClipToView", clipToView);


        context.command.BlitFullscreenTriangle(context.source, context.destination, sheet, 0);
    }
}