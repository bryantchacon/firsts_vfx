#define H 255

void GameBoyColor_float(float3 Col, out float3 Out)
{
    if(Col.r >= 0.75)
    {
        //High screen color palette
        Col = half3(202./H, 220./H, 159./H);
    }
    else if(Col.r >= 0.50 && Col.r < 0.75)
    {
        //Middle screen color palette 1
        Col = half3(139./H, 172./H, 15./H);
    }
    else if(Col.r >= 0.30 && Col.r <= 0.50)
    {
        //Middle screen color palette 2
        Col = half3(48./H, 98./H, 48./H);
    }
    else
    {
        //Low screen color palette
        Col = half3(15./H, 56./H, 15./H);
    }

    Out = Col;
}