return {
  version = "1.5",
  luaversion = "5.1",
  tiledversion = "1.8.2",
  name = "spritesheet64",
  firstgid = 1,
  tilewidth = 64,
  tileheight = 64,
  spacing = 0,
  margin = 0,
  columns = 5,
  image = "../../assets/textures/world/spritesheet64.png",
  imagewidth = 320,
  imageheight = 192,
  objectalignment = "unspecified",
  tileoffset = {
    x = 0,
    y = 0
  },
  grid = {
    orientation = "orthogonal",
    width = 64,
    height = 64
  },
  properties = {},
  wangsets = {},
  tilecount = 15,
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
            y = 56,
            width = 64,
            height = 8,
            rotation = 0,
            visible = true,
            properties = {}
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
      id = 9,
      properties = {
        ["type"] = "ground",
        ["variation"] = "white"
      }
    },
    {
      id = 10,
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
            x = 48,
            y = 0,
            width = 16,
            height = 64,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 11,
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
            x = 0,
            y = 0,
            width = 16,
            height = 64,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 12,
      properties = {
        ["position"] = "bottomLeft",
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
            x = 48,
            y = 0,
            width = 16,
            height = 64,
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
        ["position"] = "bottomRight",
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
            width = 16,
            height = 64,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    }
  }
}
