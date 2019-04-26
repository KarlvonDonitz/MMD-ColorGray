//edit by KarlVonDonitz
float Extent
<
   string UIName = "Extent";
   string UIWidget = "Slider";
   bool UIVisible =  true;
   float UIMin = 0.00;
   float UIMax = 0.01;
> = float( 0.007 );

float4 ClearColor
<
   string UIName = "ClearColor";
   string UIWidget = "Color";
   bool UIVisible =  true;
> = float4(0,0,0,0);

float Script : STANDARDSGLOBAL <
    string ScriptOutput = "color";
    string ScriptClass = "scene";
    string ScriptOrder = "postprocess";
> = 0.8;


float4 MaterialDiffuse : DIFFUSE  < string Object = "Geometry"; >;
static float alpha1 = MaterialDiffuse.a;

float Transparent : CONTROLOBJECT < string name = "(self)"; string item = "Tr"; >;
float scaling0 : CONTROLOBJECT < string name = "(self)"; >;
static float scaling = scaling0 * 0.1;


float2 ViewportSize : VIEWPORTPIXELSIZE;

static float2 ViewportOffset = (float2(0.5,0.5)/ViewportSize);

static float2 SampStep = (float2(Extent,Extent)/ViewportSize*ViewportSize.y) * scaling;


float ClearDepth  = 1.0;

texture2D DepthBuffer : RENDERDEPTHSTENCILTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    string Format = "D24S8";
>;


texture2D ScnMap : RENDERCOLORTARGET <
    float2 ViewPortRatio = {1.0,1.0};
    int MipLevels = 1;
    string Format = "A8R8G8B8" ;
>;
sampler2D ScnSamp = sampler_state {
    texture = <ScnMap>;
    MinFilter = LINEAR;
    MagFilter = LINEAR;
    MipFilter = NONE;
    AddressU  = CLAMP;
    AddressV = CLAMP;
};

struct VS_OUTPUT {
    float4 Pos            : POSITION;
    float2 Tex            : TEXCOORD0;
};

VS_OUTPUT VS_Main( float4 Pos : POSITION, float4 Tex : TEXCOORD0 ) {
    VS_OUTPUT Out = (VS_OUTPUT)0; 
    Out.Pos = Pos;
    Out.Tex = Tex + ViewportOffset;
    return Out;
}

float4 PS_Effect( float2 Tex: TEXCOORD0 ) : COLOR {   
    float4 ScnColor=tex2D( ScnSamp, Tex );
    float ColorSamp = tex2D( ScnSamp, Tex ).r*0.3+tex2D( ScnSamp, Tex ).g*0.59+tex2D( ScnSamp, Tex ).b*0.11;
    float4 Color= ColorSamp*Transparent+ScnColor*(1-Transparent);
	return Color;
}

technique Effect <
    string Script = 
        
        "RenderColorTarget0=ScnMap;"
        "RenderDepthStencilTarget=DepthBuffer;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "ScriptExternal=Color;"
        
        "RenderColorTarget0=;"
        "RenderDepthStencilTarget=;"
        "ClearSetColor=ClearColor;"
        "ClearSetDepth=ClearDepth;"
        "Clear=Color;"
        "Clear=Depth;"
        "Pass=EffectPass;"
    ;
    
> {
    pass EffectPass < string Script= "Draw=Buffer;"; > {
        AlphaBlendEnable = FALSE;
        VertexShader = compile vs_2_0 VS_Main();
        PixelShader  = compile ps_2_0 PS_Effect();
    }
}