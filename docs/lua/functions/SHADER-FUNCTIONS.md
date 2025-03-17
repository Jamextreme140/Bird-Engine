# Shader Functions

Functions to add Shaders to sprites or cameras and change their values.

##

### `initShader(name, shader, glslVersion)`

Initializes the specified shader

- name: Shader alias
- shader: Shader path, don't include the '.frag' or '.vert' extension
- glslVersion (opt.) = 120: The version that OpenGL will run the shader. Changing this will cause some issues for some graphic cards.

Returns the shader reference.

### `addShader(object, shader)`

Adds the shader to a camera or sprite.

- object: the name of the Sprite or Camera. If none are found, the shader will be added to the last camera.
- shader: Shader alias. Previously created from `initShader`.

### `removeShader(object, shader)`

Removes the shader from the sprite or camera.

- object: the name of the Sprite or Camera. If none are found, the shader will be removed from the last camera.
- shader: Shader alias. Previously created from `initShader`.

### `setShaderField(shader, field, value)`

Sets the value to the specified shader's uniform variable.
Example: `setShaderField('chrom', 'redOff', {0.0008, 0})`

- shader: Shader alias.
- field: shader's uniform variable.
- value: value to be set.

### `getShaderField(shader, field)`

- shader: Shader alias.
- field: shader's uniform variable.
