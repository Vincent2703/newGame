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
  imageheight = 110,
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
            y = 24,
            width = 32,
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
      id = 13,
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
