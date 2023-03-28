using UnityEngine;

public class VFXHalloweenController : MonoBehaviour
{
    private Material m_material;
    private GameObject m_playerPos;
    private Vector3 m_oldPlayerPos;

    void Start()
    {
        m_material = GetComponent<Renderer>().material;
        m_playerPos = GameObject.Find("Player");
        SetPlayerPosition();
    }

    void Update()
    {
        if(m_playerPos.transform.position != m_oldPlayerPos)
        {
            SetPlayerPosition();
        }
    }
    
    void SetPlayerPosition()
    {
        if(m_playerPos != null)
        {
            m_material.SetVector("_PlayerPos", m_playerPos.transform.position);
            m_oldPlayerPos = m_playerPos.transform.position;
        }
    }
}