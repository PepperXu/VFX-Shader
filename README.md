# ContourlineShading

![Demo Object Space](/Documentation/Demo01.png "demo object space")
![Demo Post Process](/Documentation/Demo02.png "demo post process")

## Features

- Support four different types of object-space contour outline and one image-space contour outline. The above image on the left shows four object-space contour outlines, which, start from the upper-left one clockwise, respectively are the vertex_unlit, fragment_surface, fragment_unlit, and vertex_surface. The above image on the right shows the image-space contour outline. 
- All types of contour outlines are independent of the depth or the distance of the camera.
- The model, Genie, inspired by Disney’s Aladdin, is created by me in Blender to demonstrate the usage of these contour shaders in real-time stylized rendering.

## Shader Properties

### Common Settings

| Common Properties        | Description                          |
|--------------------------|--------------------------------------|
| Contour Thickness    	   | The thickness of the contour         |
| Contour Color            | The color of the contour             |

### Fragment Contour Settings

| Fragment Properties      | Description                                                                   |
|--------------------------|-------------------------------------------------------------------------------|
| Depth Threshold          | The threshold for detecting edges based on the differences in depth           |
| Normal Threshold         | The threshold for detecting edges based on the differences in normal          |

### Image Space (RenderContour.cs)

| Image Properties         | Description                                                          |
|--------------------------|----------------------------------------------------------------------|
| Shader                   | Assign the image-space contour shader from the project folder        |
| Use Image Effect         | Turn the image-space shader on/off                                   |
| Depth Threshold          | Same as the fragment contour                                         |
| Normal Threshold         | Same as the fragment contour                                         |

### Unlit Settings

| Unlit Properties        | Description                          |
|-------------------------|--------------------------------------|
| Color    	          | The color tint for the main texture  |
| Texture                 | Unlit main texture                   |

### Surface Settings

| Surface Properties  | Description                                           |
|---------------------|-------------------------------------------------------|
| Color               | The color tint for main texture.                      |
| Albedo (RGB)        | Surface main texture                                  |
| Smoothness          | Control the microsurface detail of the surface        |
| Metallic            | Control the metallic reflection of the surface        |

## Implementation Details

- The RenderContour.cs is also essential for object-space fragment contours because it allows the camera to output the _CameraDepthNormalsTexture.
- The edges are detected with “the Roberts Cross” in the fragment shader. 
- The “inverted hull” technique is utilized in the vertex shader contours. In this case the scaling is done after the vertices are transformed into clip space, so that the thickness of the contour outlines is independent of the distance of the camera. However, this implementation has trouble dealing with the sharp edges (i.e. the cubes), which will “break” the outlines.

![Line Breaking](/Documentation/Break01.png "line breaking")