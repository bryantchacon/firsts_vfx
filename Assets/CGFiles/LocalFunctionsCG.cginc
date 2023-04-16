#ifndef LocalFunctionsCG
#define LocalFunctionsCG

//FUNCION PARA CREAR EL ALPHA DE UN CIRCULO DEGRADADO EN 2D
//Para poder usar esta funcion hay que agregar las siguientes propiedades en el shader con sus respectivas variables de coneccion
/*
_Radius ("Radius", Range(0.0, 0.5)) = 0.3
_Center ("Center", Range(0, 1)) = 0.5
_Smooth ("Smooth", Range(0.0, 0.5)) = 0.01
*/
float circle(float2 uvs, float center, float radius, float smooth)
{
    float c = length(uvs - center); //length() retorna la distancia entre dos puntos (por eso se guarda en una variable float de una dimension), principalmente se usa para generar circulos (como en este caso), y centrarlo en las UVs, pero tambien se puede usar para crear poligonos con los bordes redondeados
    return smoothstep(c - smooth, c + smooth, radius); //Controla el radio del circulo(por radius) y suaviza su borde. smoothstep() retorna un valor de una sola dimension, por eso se puede usar en el return, porque la funcion es de tipo float
}

//Se usa en el fragment shader asi (o adaptandolo a como se requiera):
/*
float cir = circle(i.uv, _Center, _Radius, _Smooth);

return float4(cir.xxx, 1); //Se usa .xxx como sustitutos de .xyz porque cir es de una sola dimension y la funcion debe retornar un valor de 4 dimensiones, el 1 es por que el vector es una posicion en el espacio
*/

//-------------------------------------------------------------------------------------------

//FUNCION PARA ROTAR EN 2D (SE USA DESPUES DE UnityObjectToClipPos() EN EL VERTEX SHADER)
//Para poder usar esta funcion hay que agregar la siguiente propiedad en el shader con su respectiva variable de coneccion
/*
_Center ("Center", Range(0, 1)) = 0.5
*/
float2 Rotate2D(float2 uv, float center, float speed)
{
    //Esta linea se comenta porque la funcion se trajo del script Pattern y la variable _DiagonalPivotPosition no existe en este script, en su lugar se sustituye por center de tipo float y se agrega como segundo parametro en la funcion, y en el script Pattern se pone como segundo parametro _DiagonalPivotPosition para que funcione
    // float pivot = _DiagonalPivotPosition; //Pivote, centro desde el cual girara el patron, al cambiar su valor en el inspector permite moverlo
    float pivot = center;
    //_Time, _CosTime y _SinTime son propios de ShaderLab
    //SE PUEDE JUGAR CON LOS VALORES DE cosAngle Y sinAngle CAMBIANDO LA COORDENADA DE _CosTime y _SinTime PARA TENER DIFERENTES MOVIMIENTOS EN EL PATRON
    float cosAngle = cos(_Time.y / speed); //Equivale a _CosTime.x, _Time.y = tiempo
    float sinAngle = sin(_Time.y / speed);

    float2x2 rot = float2x2 //Matriz de tiempos de _CosTime y _SinTime (_Time)
    (
        //SE PUEDE JUGAR CON LOS SIGNOS DE cosAngle Y sinAngle PARA TENER DIFERENTES MOVIMIENTOS EN EL PATRON
        cosAngle, -sinAngle,
        sinAngle, cosAngle
    );

    float2 uvPiv = uv - pivot; //Asigna el pivote de las UVs

    float2 uvRot = mul(rot, uvPiv); //Multiplica la matriz de tiempos por las UVs con el pivote asignado para poder hacer la rotacion

    return uvRot;
}

//FUNCION PARA ROTAR EN GRADOS UN PLANO
void Unity_Rotate_Degrees_float(float2 UV, float2 Center, float Rotation, out float2 Out)
{
    Rotation = Rotation * (3.1415926f/180.0f);
    UV -= Center;
    float s = sin(Rotation);
    float c = cos(Rotation);
    float2x2 rMatrix = float2x2(c, -s, s, c);
    rMatrix *= 0.5;
    rMatrix += 0.5;
    rMatrix = rMatrix * 2 - 1;
    UV.xy = mul(UV.xy, rMatrix);
    UV += Center;
    Out = UV;
}

//FUNCION FRESNEL DE SHADER GRAPH
//Para poder usar esta funcion hay que agregar los siguientes parametros en el shader en sus respectivos lugares
/*
//EN LOS VERTEX INPUT Y OUTPUT
float3 normal : NORMAL;
//VERTEX OUTPUT
float3 position_world : TEXCOORD1;
//VERTEX SHADER
o.normal = normalize(mul(unity_ObjectToWorld, float4(v.normal, 0))).xyz; //Transforma las normales a world space y las normaliza
o.position_world = mul(unity_ObjectToWorld, v.vertex).xyz; //Transforma los vertices a world space
//FRAGMENT SHADER
float3 normal_world = i.normal;
float3 view_dir = normalize(_WorldSpaceCameraPos.xyz - i.position_world).xyz;
float fresnel = 0; //Despues de esta variable se usa la funcion y se usa como su Out y por ultimo se suma a col
//PROPIEDAD
_FresnelPower ("Fresnel Power", Range(1, 2)) = 1
*/
void Unity_FresnelEffect_float(float3 Normal, float3 ViewDir, float Power, out float Out)
{
    Out = pow((1.0 - saturate(dot(normalize(Normal), normalize(ViewDir)))), Power);
}

#endif