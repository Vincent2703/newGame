return {
  version = "1.5",
  luaversion = "5.1",
  tiledversion = "1.8.2",
  name = "spritesheet",
  firstgid = 1,
  tilewidth = 32,
  tileheight = 32,
  spacing = 0,
  margin = 0,
  columns = 5,
  image = "../../assets/textures/world/spritesheet.png",
  imagewidth = 160,
  imageheight = 96,
  objectalignment = "unspecified",
  tileoffset = {
    x = 0,
    y = 0
  },
  grid = {
    orientation = "orthogonal",
    width = 32,
    height = 32
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
        ["position"] = "top",
        ["type"] = "wall",
        ["variation"] = "brick"
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
        ["position"] = "bottom",
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
            y = 28,
            width = 32,
            height = 4,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 8,
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
            y = 28,
            width = 8,
            height = 4,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 9,
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
            y = 28,
            width = 8,
            height = 4,
            rotation = 0,
            visible = true,
            properties = {}
          }
        }
      }
    },
    {
      id = 10,
      properties = {
        ["border"] = false,
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
      id = 11,
      properties = {
        ["border"] = false,
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
      id = 12,
      properties = {
        ["border"] = true,
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
      id = 13,
      properties = {
        ["border"] = true,
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
