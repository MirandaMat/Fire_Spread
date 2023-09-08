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

Este trabalho estudar a primeira etapa do trabalho: o espalhamento de fogo em paisagens homogêneas, considerando o caso 3 que há inclinacao na area de estudo e nao ha fator de vento.
--]]

-- Rascunho

SpreadFire = Model{
    dim = 50, -- Dimensão do mapa
    finalTime = 300, -- Tempo em minutos
    radius = 0, -- Raio inicial do círculo
    elevationMap = {}, -- Mapa de elevação do terreno

    init = function(model)
        -- Inicialize a matriz de alturas do terreno com valores aleatórios (0 a 100) para cada célula
        for x = 1, model.dim do
            model.elevationMap[x] = {}
            for y = 1, model.dim do
                model.elevationMap[x][y] = math.random(0, 100)
            end
        end

        -- Taxa de propagação no terreno plano (level ground)
        model.R0 = 0

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

                    print(distance)

                    -- Obtenha o ângulo de inclinação do terreno para a célula atual
                    local slope = math.atan2(model.elevationMap[cell.x][cell.y], distance) * 180 / math.pi

                    -- Calcula a taxa de propagação
                    local a = 0.0693
                    local qs = slope
                    local R = model.R0 * math.exp(a * qs)

                    if distance <= model.radius then
                        -- Considera a influência da elevação na propagação do fogo
                        local adjustedRateOfSpread = R
                        -- Ajusta o logic para a direção do vento aqui, se necessário
                        if math.random() < adjustedRateOfSpread then
                            cell.state = "burning"
                        end
                    end
                end
            end
        }

        -- Define o espaço celular
        model.cs = CellularSpace{
            xdim = model.dim,
            ydim = model.dim,
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
            target = model.cs, -- Instanciado espaço celular
            select = "state", -- Parâmetro
            value = {"unburned", "burning", "burned"}, -- Estado de transição
            grid = true, -- Grade celular visível
            color = {"green", "red", "gray"}
        }

        -- Dinâmica do modelo
        model.timer = Timer{
            Event{action = model.map},
            Event{
                period = 2, -- Ajuste do período de passo de tempo
                action = function()
                    -- Incrementa o raio do espalhamento a cada passo de tempo
                    model.radius = model.radius + 1
                end
            },
            Event{
                period = 1, -- Ajuste do período de passo de tempo
                action = model.cs
            }
        }
    end
}

SpreadFire:run()
