using UnityEngine;

[ExecuteInEditMode]
public class StarController : MonoBehaviour
{
    [SerializeField] private bool m_isActive;
    public Material m_material;

    void Start()
    {
        m_material = gameObject.GetComponent<MeshRenderer>().sharedMaterial; //Es sharedMaterial y no material por [ExecuteInEditMode], porque si no marca error
    }

    void Update()
    {
        if(m_isActive)
        {
            m_material.EnableKeyword("_ISACTIVE_ON");
            m_material.DisableKeyword("_ISACTIVE_OFF");
        }
        else
        {
            m_material.EnableKeyword("_ISACTIVE_OFF");
            m_material.DisableKeyword("_ISACTIVE_ON");
        }
    }
}