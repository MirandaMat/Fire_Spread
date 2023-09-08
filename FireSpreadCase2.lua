--[[
Instituto Nacional de Pesquisas Espaciais
Programa de Pos-Graduacao em Computacao Aplicada
CAP 466: Modelagem e Simulacao do Sistema Terrestre
Docente: Pedro Ribeiro De Andrade Neto
Discente: Mateus de Souza Miranda

Trabalho Final:
Reproducao do trabalho
Título: An improved cellular automaton model for simulating fire in a spatially heterogeneous Savanna system
Autores: Stephen G. Berjak e John W. Hearne

Este trabalho estudar a primeira etapa do trabalho: o espalhamento de fogo em paisagens homogêneas, considerando o caso 2 que ha vento e nao ha inclinacao na area de estudo.
--]]

SpreadFire = Model{
    dim = 50,
    finalTime = 300, -- Tempo em minutos
    radius = 0, -- Raio inicial do círculo
    windDirection = math.pi / 2, -- Direção do vento em radianos (2 = 360 graus, vento vindo do norte >> sul)
    windSpeed = 4, -- Velocidade do vento

    init = function(model)
        model.cell = Cell{
            -- Inicializa todas as células como não queimadas
            state = "unburned",
            -- Coordenadas do ponto de origem no centro
            x_origin = model.dim / 2,
            y_origin = model.dim / 2,
            -- Flag para verificar se a célula já foi queimada
            burned = false,
            execute = function(cell)
                if cell.state == "burning" then
                    cell.state = "burned"
                elseif cell.state == "unburned" then
                    local dx = cell.x - cell.x_origin
                    local dy = cell.y - cell.y_origin

                    -- Aplica o efeito do vento na direção e velocidade
                    local windEffect = math.cos(model.windDirection - math.atan2(dy, dx)) * model.windSpeed
                    local distance = math.sqrt(dx^2 + dy^2)

                    if distance <= model.radius + windEffect then
                        -- Atualiza o estado para burning
                        cell.state = "burning"
                    end
                end
            end
        }

        -- Define o espaço celular
        model.cs = CellularSpace{
            xdim = model.dim, -- dimensoes do espaco celular
            instance = model.cell, -- instancia as celulas
        }

        -- Vizinhança de Moore
        model.cs:createNeighborhood{strategy = "moore"}

        -- Pega a celula mais ao centro
        local mid = model.dim / 2

        -- Inicializa-a como ponto de origem do incendio
        model.cs:get(mid, mid).state = "burning"

        -- Mapa de espalhamento de fogo
        model.map = Map{
            target = model.cs, -- Instancia o espaco celular
            select = "state", -- usa o estado como ponto de
            value = {"unburned", "burning", "burned"}, -- estados de transicao
            grid = true, -- Grades das celulas visiveis
            color = {"green", "red", "gray"} -- cores dos estados
        }

        -- Dinamica do modelo
        model.timer = Timer{
            Event{action = model.map}, -- instancia o mapa com as demais instancias
            Event{
                period = 2, -- Passo de tempo
                action = function()
                    -- Incrementa o raio do espalhamento de fogo a cada passo de tempo
                    model.radius = model.radius + 1
                end
            },
            Event{
                period = 1, -- Passo de tempo
                action = model.cs -- executa o espaco celular
            }
        }
    end
}

SpreadFire:run()
