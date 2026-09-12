using UnityEngine;

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
    private bool _applied;
    
    private void Awake()
    {
        _targetRenderer = GetComponent<Renderer>();
        
        _litColorId = Shader.PropertyToID(_litColorName);
        _shadowColorId = Shader.PropertyToID(_shadowColorName);
        _shadowThresholdId = Shader.PropertyToID(_shadowThresholdName);
        _block = new MaterialPropertyBlock();
    }

    private void OnValidate()
    {
        _targetRenderer ??= GetComponent<Renderer>(); 
        _block ??= new MaterialPropertyBlock();
        
        _litColorId = Shader.PropertyToID(_litColorName);
        _shadowColorId = Shader.PropertyToID(_shadowColorName);
        _shadowThresholdId = Shader.PropertyToID(_shadowThresholdName);
        
        Apply();
    }

    private void Update()
    {
        Apply();
    }
    
    private void Apply()
    {
        if (_changeShader)
        {
            _block.SetColor(_litColorId, _litColor);
            _block.SetColor(_shadowColorId, _shadowColor);
            _block.SetFloat(_shadowThresholdId, _shadowThreshold);
        
            _targetRenderer.SetPropertyBlock(_block);
            
            _applied = true;
        }
        else if (_applied)
        {
            // Debug.Log($"{gameObject.name}: 셰이더 변경이 꺼져있어 재질 기본 값을 불러옵니다.");
            _targetRenderer.SetPropertyBlock(null);
            _applied = false;
        }
    }
}
