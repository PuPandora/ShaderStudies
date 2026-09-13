using PandoraStudio.Shader;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
[ExecuteAlways]
public class ToonShaderController : MonoBehaviour
{
    private Renderer _targetRenderer;

    [Header("- 속성")]
    [ColorUsage(true, true)]
    [SerializeField] private Color _litColor = Color.white;
    [SerializeField] private Color _shadowColor = Color.rebeccaPurple;
    [Range(0f, 1f)]
    [SerializeField] private float _shadowThreshold = 0.3f;
    [SerializeField] private bool _changeShader;

    [Header("Property")]
    [SerializeField] private ShaderProperty _litColorProperty = new ("_LitColor");
    [SerializeField] private ShaderProperty _shadowColorProperty = new ("_ShadowColor");
    [SerializeField] private ShaderProperty _shadowThresholdProperty = new ("_ShadowThreshold");

    private MaterialPropertyBlock _block;
    private void OnEnable()
    {
        Apply();
    }

    private void OnDisable()
    {
        if (_targetRenderer != null)
        {
            _targetRenderer.SetPropertyBlock(null);
        }
    }

    private void OnValidate()
    {
        Apply();
    }
    
    private void Apply()
    {
        if (_targetRenderer == null)
        {
            _targetRenderer = GetComponent<Renderer>(); 
        }
        _block ??= new MaterialPropertyBlock();
        
        if (!_changeShader)
        {
            _targetRenderer.SetPropertyBlock(null);
            return;
        }

        // 셰이더 수정, 적용
        _block.SetColor(_litColorProperty.ID, _litColor);
        _block.SetColor(_shadowColorProperty.ID, _shadowColor);
        _block.SetFloat(_shadowThresholdProperty.ID, _shadowThreshold);
    
        _targetRenderer.SetPropertyBlock(_block);
    }
}
