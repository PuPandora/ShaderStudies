using PandoraStudio.Shader;
using UnityEngine;

public class DissolvePreview : MonoBehaviour
{
    [Header("속성")]
    [SerializeField] private Renderer _targetRenderer;
    [SerializeField] private float _speed = 0.5f;
    [Range(0f, 1f)]
    [SerializeField] private float _noiseSpeed = 0.2f;
    [SerializeField] private float _min = 0f;
    [SerializeField] private float _max = 1f;
    [SerializeField] private bool _startRandomCutoff = true;
    [ColorUsage(true, true)]
    [SerializeField] private Color _dissolveColor = Color.white;
    
    [Header("Property Hash ID")]
    [SerializeField] private ShaderProperty _cutoffProperty = new ("_Cutoff");
    private ShaderProperty _dissolveColorProperty = new ("_DissolveColor");
    private ShaderProperty _noiseSpeedProperty = new ("_NoiseSpeed");
    
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
        
        _block = new MaterialPropertyBlock();
        
        // 검사
        if (!_targetRenderer.sharedMaterial.HasProperty(_cutoffProperty.ID))
        {
            Debug.LogError($"[Dissolve] {_cutoffProperty.Name} 프로퍼티가 존재하지 않습니다.");
        }

        if (!_targetRenderer.sharedMaterial.HasProperty(_dissolveColorProperty.ID))
        {
            Debug.LogError($"[Dissolve] {_dissolveColorProperty.Name} 프로퍼티가 존재하지 않습니다.");
        }

        if (!_targetRenderer.sharedMaterial.HasProperty(_noiseSpeedProperty.ID))
        {
            Debug.LogError($"[Dissolve] {_noiseSpeedProperty.Name} 프로퍼티가 존재하지 않습니다.");
        }
    }

    private void Update()
    {
        // Cutoff
        float value = Mathf.Lerp(_min, _max, Mathf.PingPong(_dissolveTime * _speed, 1f));
        _dissolveTime += Time.deltaTime;
        _block.SetFloat(_cutoffProperty.ID, value);
        
        // Color
        _block.SetColor(_dissolveColorProperty.ID, _dissolveColor);
        
        // Noise Speed
        _block.SetFloat(_noiseSpeedProperty.ID, _noiseSpeed);
        
        _targetRenderer.SetPropertyBlock(_block);
    }
}
