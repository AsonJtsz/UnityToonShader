# UnityToonShader
## A Unity ShaderLab Script

I made the shader because there is no simple and easy to use shader from asset, most of them use additional texture for lightmap, color discretization, etc. 
This shader does not require any texture setup and can be used easily.
Also, it is intended to maintain certain realistic lighting. To achieve anime feeling, only quantization of the diretional light is needed.

Copy the shader and apply it to any material

## Example

### Shader Without outline
Only Base Texture need to be set up, no need to add other texture


![image](https://user-images.githubusercontent.com/39010822/164247330-f904d5f3-f49a-4959-9c44-9a393fcac3b8.png)
![image](https://user-images.githubusercontent.com/39010822/164247612-34859f90-99e0-47e6-b3f6-64dcc1f478d7.png)

### Shader with outline and outline setting

setting script: PostProcessOutline.cs

outline method: sobel filter, robert filter and outline according to viewing normal/viewing direction from camera

![image](https://user-images.githubusercontent.com/39010822/165343631-daf3a570-04df-4e2e-af2c-4c174c950858.png)
![image](https://user-images.githubusercontent.com/39010822/165342974-05cd3871-a858-4dee-a285-1f2136c4f006.png)
![image](https://user-images.githubusercontent.com/39010822/165343055-6155a34b-b745-4e7d-8d7c-d3e324fc85e7.png)





## Standard Shader For Comparison

![image](https://user-images.githubusercontent.com/39010822/164247513-80cb7cdb-7ee0-433f-8bc6-f4afcc3a5e22.png)
