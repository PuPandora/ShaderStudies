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
    [SerializeField] private string _litColorName = "_LitColor";
    [SerializeField] private string _shadowColorName ="_ShadowColor";
    [SerializeField] private string _shadowThresholdName = "_ShadowThreshold";
    private int _litColorId;
    private int _shadowColorId;
    private int _shadowThresholdId;

    private MaterialPropertyBlock _block;
    
    private void Awake()
    {
        CacheIds();
    }

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
        CacheIds();
        Apply();
    }

    private void CacheIds()
    {
        _litColorId = Shader.PropertyToID(_litColorName);
        _shadowColorId = Shader.PropertyToID(_shadowColorName);
        _shadowThresholdId = Shader.PropertyToID(_shadowThresholdName);
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
        _block.SetColor(_litColorId, _litColor);
        _block.SetColor(_shadowColorId, _shadowColor);
        _block.SetFloat(_shadowThresholdId, _shadowThreshold);
    
        _targetRenderer.SetPropertyBlock(_block);
    }
}
