Home = class("Home")

function Home:init()
    self.GUIElements = {
        newGameBtn = RectangleButton(
            lume.round(widthWindow/3),
            lume.round(heightWindow/2)-100,
            "New game",
            function() 
                print("new game")
                server = Server()
                client = Client()
                GameState:setState("InGame")
            end
        ),
        joinGameBtn = RectangleButton(
            lume.round(widthWindow/3),
            lume.round(heightWindow/2)+100,
            "Join party",
            function() 
                print("join party") 
                client = Client()
                GameState:setState("InGame")
            end
        )
    }
end

function Home:update(dt)
    for _, item in pairs(self.GUIElements) do
        item:update(dt)
    end
end

function Home:draw()
    for _, item in pairs(self.GUIElements) do
        item:draw()
    end
end