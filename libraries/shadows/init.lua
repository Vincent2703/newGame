local Path = (...):gsub("%.", "/")
local Shadows = {}

package.loaded["shadows"] = Shadows
package.preload["libraries.shadows.Object"]			=	assert(love.filesystem.load(Path.."/Object.lua"))
package.preload["libraries.shadows.Transform"]		=	assert(love.filesystem.load(Path.."/Transform.lua"))
package.preload["libraries.shadows.LightWorld"]		=	assert(love.filesystem.load(Path.."/LightWorld.lua"))
package.preload["libraries.shadows.Light"]				=	assert(love.filesystem.load(Path.."/Light.lua"))
package.preload["libraries.shadowsStar"]				=	assert(love.filesystem.load(Path.."/Star.lua"))
package.preload["libraries.shadowsBody"]				=	assert(love.filesystem.load(Path.."/Body.lua"))
package.preload["libraries.shadowsOutputShadow"]	=	assert(love.filesystem.load(Path.."/OutputShadow.lua"))
package.preload["libraries.shadowsPriorityQueue"]	=	assert(love.filesystem.load(Path.."/PriorityQueue.lua"))

-- Shadow shapes

package.preload["libraries.shadowsShadowShapes.Shadow"]			=	assert(love.filesystem.load(Path.."/ShadowShapes/Shadow.lua"))
package.preload["libraries.shadowsShadowShapes.CircleShadow"]	=	assert(love.filesystem.load(Path.."/ShadowShapes/CircleShadow.lua"))
package.preload["libraries.shadowsShadowShapes.HeightShadow"]	=	assert(love.filesystem.load(Path.."/ShadowShapes/HeightShadow.lua"))
package.preload["libraries.shadowsShadowShapes.ImageShadow"]	=	assert(love.filesystem.load(Path.."/ShadowShapes/ImageShadow.lua"))
package.preload["libraries.shadowsShadowShapes.NormalShadow"]	=	assert(love.filesystem.load(Path.."/ShadowShapes/NormalShadow.lua"))
package.preload["libraries.shadowsShadowShapes.PolygonShadow"]	=	assert(love.filesystem.load(Path.."/ShadowShapes/PolygonShadow.lua"))

-- Rooms

package.preload["libraries.shadowsRoom"]						=		assert(love.filesystem.load(Path.."/Room/Room.lua"))
package.preload["libraries.shadowsRoom.CircleRoom"]		=		assert(love.filesystem.load(Path.."/Room/CircleRoom.lua"))
package.preload["libraries.shadowsRoom.PolygonRoom"]		=		assert(love.filesystem.load(Path.."/Room/PolygonRoom.lua"))
package.preload["libraries.shadowsRoom.RectangleRoom"]	=		assert(love.filesystem.load(Path.."/Room/RectangleRoom.lua"))

package.preload["libraries.shadowsFunctions"]				=		assert(love.filesystem.load(Path.."/Functions.lua"))
package.preload["libraries.shadows.Shaders"]					=		assert(love.filesystem.load(Path.."/Shaders.lua"))

require("libraries.shadows.Shaders")
require("libraries.shadowsFunctions")

return Shadows