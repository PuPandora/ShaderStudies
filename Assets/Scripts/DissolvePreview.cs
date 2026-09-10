using UnityEngine;

public class DissolvePreview : MonoBehaviour
{
    [Header("속성")]
    [SerializeField] private Renderer _targetRenderer;
    [SerializeField] private float _speed = 0.5f;
    [SerializeField] private float _min = 0f;
    [SerializeField] private float _max = 1f;
    [SerializeField] private bool _startRandomCutoff = true;
    [ColorUsage(true, true)]
    [SerializeField] private Color _dissolveColor = Color.white;
    
    [Header("Property Hash ID")]
    [SerializeField] private string _cutoffPropertyName = "_Cutoff";
    [SerializeField] private string _dissolveColorPropertyName = "_DissolveColor";
    private int _cutoffId;
    private int _dissolveColorId;
    
    private MaterialPropertyBlock _block;
    private float _dissolveTime;

    private void Awake()
    {
        if (_targetRenderer == null)
            _targetRenderer = GetComponent<Renderer>();

        if (_startRandomCutoff)
        {
            _dissolveTime = Random.Range(0f, 10f);
        }
        _cutoffId = Shader.PropertyToID(_cutoffPropertyName);
        _dissolveColorId = Shader.PropertyToID(_dissolveColorPropertyName);
        
        _block = new MaterialPropertyBlock();
        
        // 검사
        if (!_targetRenderer.sharedMaterial.HasProperty(_cutoffId))
        {
            Debug.LogError($"[Dissolve] {_cutoffPropertyName} 프로퍼티가 존재하지 않습니다.");
        }

        if (!_targetRenderer.sharedMaterial.HasProperty(_dissolveColorId))
        {
            Debug.LogError($"[Dissolve] {_dissolveColorPropertyName} 프로퍼티가 존재하지 않습니다.");
        }
    }

    private void OnValidate()
    {
        _cutoffId = Shader.PropertyToID(_cutoffPropertyName);
        _dissolveColorId = Shader.PropertyToID(_dissolveColorPropertyName);
    }

    private void Update()
    {
        // Cutoff
        float value = Mathf.Lerp(_min, _max, Mathf.PingPong(_dissolveTime * _speed, 1f));
        _dissolveTime += Time.deltaTime;
        
        _block.SetFloat(_cutoffId, value);
        
        // Color
        _block.SetColor(_dissolveColorId, _dissolveColor);
        
        _targetRenderer.SetPropertyBlock(_block);
    }
}
