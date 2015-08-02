// license:BSD-3-Clause
// copyright-holders:Ryan Holtz
//-----------------------------------------------------------------------------
// Effect File Variables
//-----------------------------------------------------------------------------

texture Diffuse;

sampler DiffuseSampler = sampler_state
{
	Texture   = <Diffuse>;
	MipFilter = LINEAR;
	MinFilter = LINEAR;
	MagFilter = LINEAR;
	AddressU = CLAMP;
	AddressV = CLAMP;
	AddressW = CLAMP;
};

//-----------------------------------------------------------------------------
// Vertex Definitions
//-----------------------------------------------------------------------------

struct VS_OUTPUT
{
	float4 Position : POSITION;
	float4 Color : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

struct VS_INPUT
{
	float3 Position : POSITION;
	float4 Color : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

struct PS_INPUT
{
	float4 Color : COLOR0;
	float2 TexCoord : TEXCOORD0;
};

//-----------------------------------------------------------------------------
// Simple Vertex Shader
//-----------------------------------------------------------------------------

uniform float2 ScreenDims;

uniform bool PostPass;
uniform float Brighten;

VS_OUTPUT vs_main(VS_INPUT Input)
{
	VS_OUTPUT Output = (VS_OUTPUT)0;
	
	Output.Position = float4(Input.Position.xyz, 1.0f);
	Output.Position.xy /= ScreenDims;
	Output.Position.y = 1.0f - Output.Position.y; // flip y
	Output.Position.xy -= 0.5f; // center
	Output.Position.xy *= 2.0f; // zoom

	Output.TexCoord = PostPass 
		? Input.Position.xy / ScreenDims
		: Input.TexCoord;

	Output.Color = Input.Color;

	return Output;
}

//-----------------------------------------------------------------------------
// Simple Pixel Shader
//-----------------------------------------------------------------------------

float4 ps_main(PS_INPUT Input) : COLOR
{
	float4 BaseTexel = tex2D(DiffuseSampler, Input.TexCoord);
	return BaseTexel * (Input.Color + float4(Brighten, Brighten, Brighten, 0.0f));
}

//-----------------------------------------------------------------------------
// Simple Effect
//-----------------------------------------------------------------------------

technique TestTechnique
{
	pass Pass0
	{
		Lighting = FALSE;

		Sampler[0] = <DiffuseSampler>;

		VertexShader = compile vs_2_0 vs_main();
		PixelShader  = compile ps_2_0 ps_main();
	}
}
