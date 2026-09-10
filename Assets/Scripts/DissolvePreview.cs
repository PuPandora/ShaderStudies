using System;
using UnityEngine;

public class DissolvePreview : MonoBehaviour
{
    [SerializeField] private Renderer _targetRenderer;
    [SerializeField] private string _cutoffPropertyName = "_Cutoff";
    [SerializeField] private float _speed = 0.5f;
    [SerializeField] private float _min = 0f;
    [SerializeField] private float _max = 1f;

    private int _cutoffId;
    private MaterialPropertyBlock _block;

    private void Awake()
    {
        if (_targetRenderer == null)
            _targetRenderer = GetComponent<Renderer>();

        _cutoffId = Shader.PropertyToID(_cutoffPropertyName);
        _block = new MaterialPropertyBlock();
    }

    private void Update()
    {
        float value = Mathf.Lerp(_min, _max, Mathf.PingPong(Time.time * _speed, 1f));

        _targetRenderer.GetPropertyBlock(_block);
        _block.SetFloat(_cutoffId, value);
        _targetRenderer.SetPropertyBlock(_block);
    }
}
