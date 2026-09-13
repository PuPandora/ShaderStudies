namespace PandoraStudio.Shader
{
    using UnityEngine;
    
    [System.Serializable]
    public struct ShaderProperty
    {
        [SerializeField] private string _name;
        public string Name => _name;
        
        public int ID => Shader.PropertyToID(_name);

        public ShaderProperty(string name)
        {
            _name = name;
        }

        public void SetName(string name)
        {
            _name = name;
        }
    }
}
