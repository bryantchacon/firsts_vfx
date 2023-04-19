using UnityEngine;

//ESTE SCRIPT VA EN LA CAMARA

[ExecuteInEditMode]
public class PostProcessingScript : MonoBehaviour
{
    public Material effect; //Material con el shader que se le aplicara al render final de la camara, recibe como material el que tenga el shader PostProcessing

    void Start()
    {
        SetPixelSize();
    }

    private void OnRenderImage(RenderTexture source, RenderTexture destination) //source es el render de la camara y destination el render final con el shader aplicado
    {
        Graphics.Blit(source, destination, effect); //Blit() copia el render original del render de la camara para usarlo con le shader que se le agregara despues, el cual se indica con effect
    }

    private void SetPixelSize() //Corrige el tamaño del pixel segun el aspect ratio de la camara
    {
        Vector2 aspectRatio = AspectRatio.GetAspectRatio(Screen.width, Screen.height); //Obtiene el aspect ratio de la camara
        float minValue = Mathf.Min(aspectRatio.x, aspectRatio.y);

        //Voltean los valores para que los pixeles sean cuadrados sin importar el aspect ratio de la camara
        float ratio_x = aspectRatio.y / minValue;
        float ratio_y = aspectRatio.x / minValue;

        float pixelSize = Mathf.Max(ratio_x, ratio_y); //Calcula la escala de un pixel

        //Setean los valores de las respectivas propiedades en el shader PostProcessing
        effect.SetFloat("_RatioX", ratio_x);
        effect.SetFloat("_RatioY", ratio_y);
        effect.SetFloat("_PixelSize", pixelSize);
    }
}