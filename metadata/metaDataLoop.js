const fs = require('fs');

let metaTemplate = {
  "title": "Token Metadata",
  "type": "object",
  "properties": {
      "name": {
          "type": "string",
          "description": "Identifies the asset to which this token represents"
      },
      "description": {
          "type": "string",
          "description": "Describes the asset to which this token represents"
      },
      "image": {
          "type": "string",
          "description": "A URI pointing to a resource with mime type image/* representing the asset to which this token represents. Consider making any images at a width between 320 and 1080 pixels and aspect ratio between 1.91:1 and 4:5 inclusive."
      },
      "properties": {
          "type": "object",
          "description": "Arbitrary properties. Values may be strings, numbers, object or arrays."
      }
  }
}

for (let i = 0; i < 10; i++ ){
  for(let j = 0; j < 4; j++) {

  }
}