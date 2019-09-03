# Procedural Checkerboard

A spatial material useful for blocking out levels. It is fully procedural and does not require UV maps.

![example](/ProceduralCheckerboard/screenshot.png)

The checkerbord is generated without textures and utilizes high quality filtering. There are a few parameters (albedo color, roughness, metallic, detail texture) to adjust the visuals of the material.

## Files

Files | Description
--- | ---
[ProcCheckers.shader](/ProceduralCheckerboard/ProcCheckers.shader) | Base shader
[ProcCheckersDetail.shader](/ProceduralCheckerboard/ProcCheckersDetail.shader) | Same shader with optional detail texture
