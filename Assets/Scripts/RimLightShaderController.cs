using PandoraStudio.Shader;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
[ExecuteAlways]
public class RimLightShaderController : MonoBehaviour
{
    private Renderer _targetRenderer;
    
    [Header("- 속성")]
    [SerializeField] private Color _baseColor = new Color(0.15f, 0.15f, 0.15f, 1f);
    [ColorUsage(true, true)]
    [SerializeField] private Color _rimColor = Color.white;
    [Range(0f, 8f)]
    [SerializeField] private float _rimPower = 8.0f;
    [SerializeField] private bool _changeShader = true;

    [Header("Property")]
    private static readonly ShaderProperty BaseColorProperty = new ("_BaseColor");
    [SerializeField] private ShaderProperty _rimColorProperty = new ("_RimColor");
    [SerializeField] private ShaderProperty _rimPowerProperty = new ("_RimPower");

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
        
        _block.SetColor(BaseColorProperty.ID, _baseColor);
        _block.SetColor(_rimColorProperty.ID, _rimColor);
        _block.SetFloat(_rimPowerProperty.ID, _rimPower);
        
        _targetRenderer.SetPropertyBlock(_block);
    }
}
