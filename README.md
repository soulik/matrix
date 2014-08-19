Matrix
=====

Matrix is 4x4 matrix manipulation library. Useful for affine transformations in 3D space.
This library uses row-based memory addresation. So if you want to use this library with OpenGL, don't forget to use transposition before passing matrix to OpenGL!

Usage
=====
```lua
local matrix = require 'matrix'
```

## Initialization
```lua
-- identity
local M0 = matrix() 

local M1 = M0.identity()

-- custom matrix
local M2 = matrix({
	1, 0, 0, 0,
	0, 1, 0, 0,
	0, 0, 1, 0, 
	0, 0, 0, 1
})
```

## Translation
```lua
local translationMatrix0 = M0.translate(x, y, z)
local translationMatrix1 = M0.translateX(x)
local translationMatrix2 = M0.translateY(y)
local translationMatrix3 = M0.translateZ(z)
```

## Rotation
```lua
local rotationMatrix0 = M0.rotate(x, y, z, angle)
local rotationMatrix1 = M0.rotateX(angle)
local rotationMatrix2 = M0.rotateY(angle)
local rotationMatrix3 = M0.rotateZ(angle)
```

## Scale
```lua
local scaleMatrix0 = M0.scale(x, y, z)
local scaleMatrix1 = M0.scaleX(x)
local scaleMatrix2 = M0.scaleY(y)
local scaleMatrix3 = M0.scaleZ(z)
```

## Skew
```lua
local skewMatrix = M0.skew(x, y, z)
```

## Transpose
```lua
local transposedMatrix = M1.transpose()
```

## Matrix operations
```lua
local newMatrix = M0*M1 + M2
```

## Element access
```lua
-- second row, third column
local x,y = 3,2
local element = M0[(y-1)*4 + x]
```