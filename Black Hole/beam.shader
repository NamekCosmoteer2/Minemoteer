#define USE_DEFAULT_VERT
#include "./Data/base.shader"

float _length;

float _sizePulseFactor;
float _sizePulseInterval;
float _sizePulseUOffsetFactor;

float4 getBaseColor(VERT_OUTPUT input)
{
	float L = _length;

	// Calc desired X sample pos wrt current Y pos
	float sizePulseTX = wave(_gameTime + input.uv.y * L/2 * _sizePulseUOffsetFactor, _sizePulseInterval);
	float normalizedX = input.uv.x * 2 - 1;
	normalizedX /= lerp(1, _sizePulseFactor, sizePulseTX);
	float dX = (normalizedX + 1) / 2;

	// Discard flag end to emulate fluttering
	if ( dX > 0.92 )
		discard;

	// Calc desired Y sample pos wrt current X pos
	float sizePulseTY = wave(_gameTime + input.uv.x * L * _sizePulseUOffsetFactor, _sizePulseInterval);
	float normalizedY = input.uv.y * 2 - 1;
	normalizedY /= lerp(1, _sizePulseFactor, sizePulseTY);
	float dY = (normalizedY + 1) / 2;	

	return _texture.Sample(_texture_SS, float2(dX, dY));
}


PIX_OUTPUT pix(in VERT_OUTPUT input) : SV_TARGET
{
	float4 baseColor = getBaseColor(input);
	
	baseColor.a *= min((1 - input.uv.x) * _length / _sizePulseFactor, 1);
	baseColor *= input.color;

	if(baseColor.a <= 0)
		discard;
	return baseColor;
}
