using System;
using UnityEngine;

[RequireComponent(typeof(Renderer))]
[ExecuteAlways]
public class RimLightShaderController : MonoBehaviour
{
    private Renderer _targetRenderer;
    
    [Header("- 속성")]
    [SerializeField] private Color _baseColor = new Color(0.15f, 0.15f, 0.15f, 1f);
    [ColorUsage(true, true)]
    [SerializeField] private Color _rimColor = Color.white * 2f;
    [Range(0f, 8f)]
    [SerializeField] private float _rimPower = 8.0f;
    [SerializeField] private bool _changeShader = true;

    [Header("Property")]
    [SerializeField] private string _baseColorName = "_BaseColor";
    [SerializeField] private string _rimColorName ="_RimColor";
    [SerializeField] private string _rimPowerName = "_RimPower";
    private int _baseColorId;
    private int _rimColorId;
    private int _rimPowerId;

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

    private void CacheIds()
    {
        _baseColorId = Shader.PropertyToID(_baseColorName);
        _rimColorId = Shader.PropertyToID(_rimColorName);
        _rimPowerId = Shader.PropertyToID(_rimPowerName);
    }

    private void OnValidate()
    {
        CacheIds();
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
        
        _block.SetColor(_baseColorId, _baseColor);
        _block.SetColor(_rimColorId, _rimColor);
        _block.SetFloat(_rimPowerId, _rimPower);
        
        _targetRenderer.SetPropertyBlock(_block);
    }
}
