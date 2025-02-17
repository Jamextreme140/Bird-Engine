# Reflection Functions

Functions to get/set properties from Objects and call their methods.

## Getting values

### `getField(field)`

Returns the property or variable value from the current state. For objects created from Lua, refer to `getObjectField`.

- field: The field to fetch.

### `getArrayField(field, index, arrayField)`

Returns the property or variable value in the given index of an array.

- field: The array or FlxGroup to fetch.
- index: The array index (or the FlxGroup member index).
- arrayField: The field to fetch.

### `getObjectField(object, field)`

Returns the property or variable value from the object (sprite, text or some other created from Lua). For current state objects, refer to `getObjectField`.

- object: The referenced object
- field: The field to fetch.

### `getClassField(className, field)`

Returns the property or variable value from a given class.

- className: The full path to the class. Example: 'flixel.FlxG', 'funkin.game.PlayState'.
- field: The field to fetch.

### `getParentField(field)`

- field: The field to fetch

### `getParentArrayField(field, index, arrayField)`

- field: The array or FlxGroup to fetch.
- index: The array index (or the FlxGroup member index).
- arrayField: The field to fetch.

## Setting values

### `setField(field, value)`

Sets the property or variable value from the current state. For objects created from Lua, refer to `setObjectField`.

- field: The field to fetch.
- value: The value to set to the field.

### `setArrayField(field, index, arrayField, value)`

Sets the property or variable value in the given index of an array.

- field: The array or FlxGroup to fetch.
- index: The array index (or the FlxGroup member index).
- arrayField: The field to fetch.
- value: The value to set to the field.

### `setObjectField(object, field, value)`

Sets the property or variable value from the object (sprite, text or some other created from Lua). For current state objects, refer to `setField`.

- object: The referenced object
- field: The field to fetch.
- value: The value to set to the field.

### `setClassField(className, field, value)`

Sets the property or variable value from a given class.

- className: The full path to the class. Example: 'flixel.FlxG', 'funkin.game.PlayState'.
- field: The field to fetch.
- value: The value to set to the field.

### `setParentField(field, value)`

- field: The field to fetch
- value: The value to set to the field.

### `setParentArrayField(field, index, arrayField, value)`

- field: The array or FlxGroup to fetch.
- index: The array index (or the FlxGroup member index).
- arrayField: The field to fetch.
- value: The value to set to the field.

## Calling functions

### `callMethod(function, args)`

Call an specified `function` of the current state/substate with the given arguments `args`.

- function: Functions to call
- args (opt.): Function arguments

### `callObjectMethod(object, function, args)`

Call an specified `function` of the specified `object`, like a sprite, with the given arguments `args`.

Example: `callObjectMethod('aSprite', 'setPosition', {100, 100})`

- object: The referenced object
- function: Functions to call
- args (opt.): Function arguments

### `callClassMethod(className, function, args)`

Call an specified `function` of the specified `className` with the given arguments `args`.

- className: The referenced class. Must be the full path (Ex: 'flixel.FlxG')
- function: Functions to call
- args (opt.): Function arguments
