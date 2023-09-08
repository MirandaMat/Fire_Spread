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

Este trabalho estudar a primeira etapa do trabalho: o espalhamento de fogo em paisagens homogêneas, considerando o caso 1 que nao ha vento e inclinacao na area de estudo.
--]]

SpreadFire = Model{
    dim = 50, -- Dimensao do mapa
    finalTime = 300, -- Tempo em minutos
    radius = 0, -- Raio inicial do círculo

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
                    local distance = math.sqrt(dx^2 + dy^2)
                    if distance <= model.radius then
                        -- Atualiza o estado para burning
                        cell.state = "burning"
                    end
                end
            end
        }

        -- Define o espaço celular
        model.cs = CellularSpace{
            xdim = model.dim,
            instance = model.cell,
        }

        -- Vizinhança de Moore
        model.cs:createNeighborhood{strategy = "moore"} -- Moore

        -- Pega o centro
        local mid = model.dim / 2

        -- Inicializa o círculo de células criando um ponto de origem no centro
        model.cs:get(mid, mid).state = "burning"

        -- Mapa de espalhamento de fogo
        model.map = Map{
            target = model.cs, -- Instanciado espaco celular
            select = "state", -- Parametro
            value = {"unburned", "burning", "burned"}, -- Estado de transicao
            grid = true, -- Grade celular visivel
            color = {"green", "red", "gray"}
        }

        -- Dinamica do modelo
        model.timer = Timer{
            Event{action = model.map},
            Event{
                period = 2, -- Ajuste o período de passo de tempo
                action = function()
                    -- Incrementa o raio do espalhamento a cada passo de tempo
                    model.radius = model.radius + 1
                end
            },
            Event{
                period = 1, -- Ajuste o período de passo de tempo
                action = model.cs
            }
        }
    end
}

SpreadFire:run()
