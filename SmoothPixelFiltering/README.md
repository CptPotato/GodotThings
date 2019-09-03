# Smooth Pixel Filtering
A shader snippet allowing for "smooth pixelated" filtering, eliminating most aliasing artifacts. This **requires** the `Filter` flag of the texture to be set and supports *Mipmapping* and *Anisotropic Filtering*. The effect looks similar to super-sampling but there should be no noticable impact on performance.

*Note: This may not work on GLES 2*

## 2D

In 2D, this will *eliminate aliasing artifacts* (often called *jitter*) on the texture and greatly improve the *smoothness* of scaled or rotated graphics. Integer scales will remain pixel-perfect while non-integer scales produce a softer, antialiased look.
It is useful for the final scaling pass or when rendering low resolution pixel art in a higher resolution game.

**Here's a video by [Heartbeast](https://github.com/uheartbeast) showing the effect in motion: https://youtu.be/2JbhkZe22bE**

![edample 2D](/SmoothPixelFiltering/screenshot_2d.png)
![example 2D_2x](/SmoothPixelFiltering/screenshot_2d_2x.png)

## 3D

In 3D the same benefits apply but are often more impactful because of the varying perspective and sometimes steep camera angles.

![example 3D](/SmoothPixelFiltering/screenshot_3d.png)

## Files

Files | Description
--- | ---
[SmoothPixel.shader](/SmoothPixelFiltering/SmoothPixel.shader) | 2D shader
[SmoothPixelManual.shader](/SmoothPixelFiltering/SmoothPixelManual.shader) | Alternative 2D shader with **manual** filtering **\***
[SmoothPixel3D.shader](/SmoothPixelFiltering/SmoothPixel3D.shader) | 3D example shader for the algorithm

\* *This one requires you to calculate the width of the filter manually which is a bit cumbersome. It's only recommended for special use cases or when you're having compatibility issues.*

## The Algorithm

Here's the basic algorithm. The filtering happens automatically and is based on the derivatives of the `uv` parameter.

Parameters
- `smp` texture sampler
- `uv` texture coordinate
- `pixel_size` size of one pixel of the texture (1.0f / dimensions)

```glsl
vec4 texturePointSmooth(sampler2D smp, vec2 uv, vec2 pixel_size)
{
	vec2 ddx = dFdx(uv);
	vec2 ddy = dFdy(uv);
	vec2 lxy = sqrt(ddx * ddx + ddy * ddy);
	
	vec2 uv_pixels = uv / pixel_size;
	
	vec2 uv_pixels_floor = round(uv_pixels) - vec2(0.5f);
	vec2 uv_dxy_pixels = uv_pixels - uv_pixels_floor;
	
	uv_dxy_pixels = clamp((uv_dxy_pixels - vec2(0.5f)) * pixel_size / lxy + vec2(0.5f), 0.0f, 1.0f);
	
	uv = uv_pixels_floor * pixel_size;
	
	return textureGrad(smp, uv + uv_dxy_pixels * pixel_size, ddx, ddy);
}
```
