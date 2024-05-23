return {
  version = "1.5",
  luaversion = "5.1",
  tiledversion = "1.8.2",
  name = "tileset",
  firstgid = 1,
  tilewidth = 32,
  tileheight = 32,
  spacing = 1,
  margin = 1,
  columns = 5,
  image = "../../assets/textures/world/spritesheet.png",
  imagewidth = 180,
  imageheight = 133,
  objectalignment = "topleft",
  tileoffset = {
    x = 1,
    y = 1
  },
  grid = {
    orientation = "orthogonal",
    width = 32,
    height = 32
  },
  properties = {},
  wangsets = {},
  tilecount = 20,
  tiles = {
    {
      id = 0,
      properties = {
        ["type"] = "ground",
        ["variation"] = "wood"
      }
    },
    {
      id = 1,
      properties = {
        ["type"] = "ground",
        ["variation"] = "wood"
      }
    },
    {
      id = 2,
      properties = {
        ["position"] = "front",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 0,
            y = 31,
            width = 32,
            height = 1,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 3,
      properties = {
        ["position"] = "leftRightTop",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 0,
            y = 31,
            width = 32,
            height = 1,
            rotation = 0,
            visible = true,
            properties = {
              ["position"] = "leftRightTop",
              ["type"] = "wall",
              ["variation"] = "brick"
            }
          }
        }
      }
    },
    {
      id = 4,
      properties = {
        ["type"] = "ground",
        ["variation"] = "green"
      }
    },
    {
      id = 5,
      properties = {
        ["type"] = "ground",
        ["variation"] = "wood"
      }
    },
    {
      id = 6,
      properties = {
        ["type"] = "ground",
        ["variation"] = "wood"
      }
    },
    {
      id = 7,
      properties = {
        ["position"] = "topLeftCorner",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 0,
            y = 31,
            width = 32,
            height = 1,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 8,
      properties = {
        ["position"] = "topRightCorner",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 0,
            y = 31,
            width = 32,
            height = 1,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 9,
      properties = {
        ["type"] = "ground",
        ["variation"] = "white"
      }
    },
    {
      id = 12,
      properties = {
        ["position"] = "bottomLeftCorner",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 0,
            y = 0,
            width = 8,
            height = 32,
            rotation = 0,
            visible = true,
            properties = {}
          },
          {
            id = 3,
            name = "",
            type = "",
            shape = "rectangle",
            x = 8,
            y = 31,
            width = 24,
            height = 1,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 13,
      properties = {
        ["position"] = "bottomRightCorner",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 24,
            y = 0,
            width = 8,
            height = 32,
            rotation = 0,
            visible = true,
            properties = {}
          },
          {
            id = 2,
            name = "",
            type = "",
            shape = "rectangle",
            x = 0,
            y = 31,
            width = 24,
            height = 1,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 15,
      properties = {
        ["position"] = "right",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 24,
            y = 0,
            width = 8,
            height = 32,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 16,
      properties = {
        ["position"] = "left",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 0,
            y = 0,
            width = 8,
            height = 32,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 17,
      properties = {
        ["position"] = "insideRightCorner",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 24,
            y = 0,
            width = 8,
            height = 32,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 18,
      properties = {
        ["position"] = "insideLeftCorner",
        ["type"] = "wall",
        ["variation"] = "brick"
      },
      objectGroup = {
        type = "objectgroup",
        draworder = "index",
        id = 2,
        name = "",
        visible = true,
        opacity = 1,
        offsetx = 0,
        offsety = 0,
        parallaxx = 1,
        parallaxy = 1,
        properties = {},
        objects = {
          {
            id = 1,
            name = "",
            type = "",
            shape = "rectangle",
            x = 0,
            y = 0,
            width = 8,
            height = 32,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    }
  }
}
