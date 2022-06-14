--local physics = require( "physics" )
--physics.start()
--physics.setDrawMode( "hybrid" )
--physics.setGravity( 0, 0 )

local velocidadeRaquete = 20
local velocidadeBola = 20


local fundo = display.newRect(display.contentCenterX,display.contentCenterY,display.contentWidth,display.contentHeight)
fundo:setFillColor(0,0,1);

local paredeSuperior = display.newRect(display.contentCenterX, 0,display.contentWidth,20)
--physics.addBody( paredeSuperior, "static")
local paredeInferior = display.newRect(display.contentCenterX, display.contentHeight,display.contentWidth,20)
--physics.addBody( paredeInferior, "static")
local paredeEsquerda = display.newRect(0, display.contentCenterY, 20, display.contentHeight)
paredeEsquerda.nome = "paredeEsquerda"
--physics.addBody( paredeEsquerda, "static")
local paredeDireita = display.newRect(display.contentWidth, display.contentCenterY, 20, display.contentHeight)
paredeDireita.nome = "paredeDireita"
--physics.addBody( paredeDireita, "static")

local raquete = display.newRect(30, display.contentCenterY,10,110)
--physics.addBody( raquete, "static")

local bola = display.newCircle(display.contentCenterX,display.contentCenterY,10)
bola.velocidadeX = velocidadeBola
bola.velocidadeY = velocidadeBola
bola:setFillColor(1,0,0)
--physics.addBody( bola, { radius=10, bounce=1 } )

--bola:setLinearVelocity( math.random(-1,1)*200, math.random(-100,100) )

local function lerTeclado(event)
    print("Tecla '" .. event.keyName .. "' pressionada " .. event.phase)

    if(event.keyName == "up") then
        if(raquete.y > 0 )then
            raquete.y = raquete.y - velocidadeRaquete
        end
    end
    if(event.keyName == "down") then
        if(raquete.y < display.contentHeight )then
            raquete.y = raquete.y + velocidadeRaquete
        end
    end
end

local function moveRaquete(probabilidade_)
    if(probabilidade_ > .5) then
        if(raquete.y > 0 )then
            raquete.y = raquete.y - velocidadeRaquete
        end
    elseif(probabilidade_ < .5) then
        if(raquete.y < display.contentHeight )then
            raquete.y = raquete.y + velocidadeRaquete
        end
    end
end

local function moveBola()
    bola.x = bola.x + bola.velocidadeX
    bola.y = bola.y + bola.velocidadeY

    if(bola.x <= 0) then
        bola.velocidadeX = velocidadeBola
    end
    if(bola.y <= 0) then
        bola.velocidadeY = velocidadeBola
    end
    if(bola.x >= display.contentWidth) then
        bola.velocidadeX = -velocidadeBola
    end
    if(bola.y >= display.contentHeight) then
        bola.velocidadeY = -velocidadeBola
    end

    --FALTA ARRUMAR A COLISÃO COM A RAQUETE
    --//////////////////////////////////////
    if(bola.x - 20 <= raquete.x + raquete.width) and (bola.y < raquete.y + raquete.height) then
         if((bola.y > raquete.y  - raquete.height) and (bola.y < raquete.y + raquete.height))then
            bola.velocidadeX = velocidadeBola
     end

 end


end
timerloopBola = timer.performWithDelay( 50, moveBola, 0 )

Runtime:addEventListener( "key", lerTeclado )



-- /////////////////////REDE NEURAL////////////////////
local alpha = 0.01
math.randomseed(os.clock())
local ultimasEntradas = {{},{},{}}
local pesos = {
    { -- neuronios camada 1
        {--neuronio 1 camada 1
            math.random(-100, 100)/100,
            math.random(-100, 100)/100,
            math.random(-100, 100)/100,
            math.random(-100, 100)/100,
        }, 
        {--neuronio 2 camada 1
            math.random(-100, 100)/100,
            math.random(-100, 100)/100,
            math.random(-100, 100)/100,
            math.random(-100, 100)/100,
        } 
    },
    { --neuronios camada 2 (oculta)
        {--neuronio 1 camada 2
            math.random(-100, 100)/100,
            math.random(-100, 100)/100,
        }, 
        {--neuronio 2 camada 2
            math.random(-100, 100)/100,
            math.random(-100, 100)/100,
        } 
    },
    { --neuronio camada 3 (saida)
        {--neuronio 1 camada 3
            math.random(-100, 100)/100,
            math.random(-100, 100)/100,
        }, 
    }
}

print('\nPesos: ')
for i = 1,#pesos do
    for j = 1,#pesos[i] do
        print('Camada ['..i..'] - Neuronio ['..j..']:')
        for k = 1, #pesos[i][j] do
            print('--['..k..'] = '..pesos[i][j][k])
        end
    end
end
print('\nCalculos:::::::::::\n')

local function tangenteHiperbolica(valor)
    return (math.exp(valor) - math.exp(-valor)) / (math.exp(valor) + math.exp(-valor))
end

local function sigmoid(valor)
    return 1 / (1 + math.exp(-valor))
end

local function somatorio(pesos_, entradas_)
    local somatorio = 0
	  for i=1, #pesos_ do
	    somatorio = somatorio + entradas_[i] * pesos_[i]
      print('entrada ['..i..'] '..entradas_[i]..' * '..pesos_[i]..' = '..entradas_[i] * pesos_[i])
    end
    print('Somatorio::: '..somatorio)
    return somatorio
end

local function calculoPrimeiraCamada(idNeuronio, entradas_)
    ultimasEntradas[1][idNeuronio] = entradas_
    print('Calculo Camada [1] Neuronio ['..idNeuronio..']:::')

    local resultado = tangenteHiperbolica(somatorio(pesos[1][idNeuronio], entradas_))

    print('Resultado Camada[1] Neuronio ['..idNeuronio..']::: '..resultado)

    return resultado
end
local function calculoSegundaCamada(idNeuronio, entradas_)
    ultimasEntradas[2][idNeuronio] = entradas_
    print('Calculo Camada [2] Neuronio ['..idNeuronio..']:::')

    local resultado = tangenteHiperbolica(somatorio(pesos[2][idNeuronio], entradas_))

    print('Resultado Camada[2] Neuronio ['..idNeuronio..']::: '..resultado)

    return resultado
end
local function calculoTerceiraCamada(idNeuronio, entradas_)
    ultimasEntradas[3][idNeuronio] = entradas_
    print('Calculo Camada [3] Neuronio ['..idNeuronio..']:::')

    local resultado = sigmoid(somatorio(pesos[3][idNeuronio], entradas_))

    print('Resultado Camada[3] Neuronio ['..idNeuronio..']::: '..resultado)

    return resultado
end

local function calculoNeural()

    local entradasPrimeiraCamada = {
        raquete.y / display.contentHeight,
        bola.x / display.contentWidth,
        bola.y  / display.contentHeight,
        -1 --bias
    }

    local camada1Neuronio1 = calculoPrimeiraCamada(1, entradasPrimeiraCamada)
    print('\n')
    local camada1Neuronio2 = calculoPrimeiraCamada(2, entradasPrimeiraCamada)
    print('\n')

    local entradasSegundaCamada = {
        camada1Neuronio1,
        camada1Neuronio2,
    }

    local camada2Neuronio1 = calculoSegundaCamada(1, entradasSegundaCamada)
    print('\n')
    local camada2Neuronio2 = calculoSegundaCamada(2, entradasSegundaCamada)
    print('\n')

    local entradasTerceiraCamada = {
        camada2Neuronio1,
        camada2Neuronio2,
    }

    local camada3Neuronio1 = calculoTerceiraCamada(1, entradasTerceiraCamada)
    print('\n')

    moveRaquete(camada3Neuronio1)

end

local function atualizaPesos(erro_)
    print('Atualizando pesos\n')

    for i = 1,#pesos do
        for j = 1,#pesos[i] do
            print('Camada ['..i..'] - Neuronio ['..j..']:')
            for k = 1, #pesos[i][j] do
                local novoPeso = pesos[i][j][k] + (alpha * ultimasEntradas[i][j][k] * erro_)

                pesos[i][j][k] = novoPeso
                
            end
            print('\n')
        end
    end

end


local function colisaoParede(self, event)
    if ( event.phase == "began" ) then
        --print( self.nome .. " colidiu " )
        if(self.nome == 'paredeEsquerda')then
            --calculoNeural(raquete.y, bola.x, bola.y)
        end
    end
end
paredeDireita.collision = colisaoParede
paredeDireita:addEventListener( "collision" )
paredeEsquerda.collision = colisaoParede
paredeEsquerda:addEventListener( "collision" )

local function loopNeural()

    calculoNeural()

    atualizaPesos((raquete.y - bola.y)/100)

end


timerLoopNeural = timer.performWithDelay( 50, loopNeural, 0 )