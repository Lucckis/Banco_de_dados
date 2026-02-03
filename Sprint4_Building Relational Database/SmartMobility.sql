CREATE TABLE T_USUARIO(
    id_usuario INTEGER PRIMARY KEY NOT NULL,
    nm_usuario VARCHAR2(100),
    preferencias CLOB
)

CREATE TABLE T_COORDENADA(
    id_localizacao INTEGER PRIMARY KEY NOT NULL,
    latitude NUMBER(10,8) NOT NULL,
    longitude NUMBER(11,8) NOT NULL
)

CREATE TABLE T_ESTACAO(
    id_estacao INTEGER PRIMARY KEY NOT NULL,
    id_localizacao INTEGER NOT NULL,
    nm_estacao VARCHAR2(100) NOT NULL,
    endereco VARCHAR2(100) UNIQUE NOT NULL,
    acessibilidade CLOB,
    CONSTRAINT FK_localizacao FOREIGN KEY (id_localizacao) 
    REFERENCES T_COORDENADA
)

CREATE TABLE T_CHATBOT(
    id_chatbot INTEGER PRIMARY KEY NOT NULL,
    id_estacao INTEGER NOT NULL,
    id_usuario INTEGER NOT NULL,
    dt_hr_interacao DATE NOT NULL,
    pergunta_usuario CLOB NOT NULL,
    resposta_chatbot CLOB NOT NULL,
    CONSTRAINT FK_estacaoV2 FOREIGN KEY (id_estacao) REFERENCES T_ESTACAO,
    CONSTRAINT FK_usuario FOREIGN KEY (id_usuario) REFERENCES T_USUARIO
)

CREATE TABLE T_TOTEM(
    id_totem INTEGER PRIMARY KEY NOT NULL,
    id_estacao INTEGER NOT NULL,
    id_chatbot INTEGER NOT NULL,
    status_operacional CHAR(90) NOT NULL,
    CONSTRAINT FK_estacao FOREIGN KEY (id_estacao) REFERENCES T_ESTACAO,
    CONSTRAINT FK_chatbot FOREIGN KEY (id_chatbot) REFERENCES T_CHATBOT
)

CREATE TABLE T_SERVICO_METRO(
    id_servico INTEGER PRIMARY KEY NOT NULL,
    id_estacao INTEGER NOT NULL,
    nm_servico VARCHAR2(100) NOT NULL,
    ds_servico VARCHAR2(255) NOT NULL,
    CONSTRAINT FK_estacaoV3 FOREIGN KEY (id_estacao)
    REFERENCES T_ESTACAO
)

CREATE TABLE T_ROTA(
    id_rota INTEGER PRIMARY KEY NOT NULL,
    id_estacao INTEGER NOT NULL,
    estacao_inicial VARCHAR2(100) NOT NULL,
    estacao_final VARCHAR2(100) NOT NULL,
    distancia NUMBER(5,2) NOT NULL,
    duracao DATE NOT NULL,
    tipo_rota VARCHAR2(50),
    CONSTRAINT FK_estacaoV4 FOREIGN KEY (id_estacao) 
    REFERENCES T_ESTACAO   
)

CREATE TABLE T_PONTO_TURISTICO(
    id_ponto_turistico INTEGER PRIMARY KEY NOT NULL,
    id_estacao INTEGER NOT NULL,
    id_localizacao INTEGER NOT NULL,
    nm_ponto_turistico VARCHAR2(100) NOT NULL,
    ds_ponto_turistico VARCHAR2(255) NOT NULL,
    hr_funcionamento_ponto VARCHAR2(50),
    CONSTRAINT FK_estacaoV5 FOREIGN KEY (id_estacao) REFERENCES T_ESTACAO,
    CONSTRAINT FK_localizacaoV2 FOREIGN KEY (id_localizacao) 
    REFERENCES T_COORDENADA
)

CREATE TABLE T_RESTAURANTE(
    id_restaurante INTEGER PRIMARY KEY NOT NULL,
    id_estacao INTEGER NOT NULL,
    id_ponto_turistico INTEGER NOT NULL,
    nm_restaurante VARCHAR2(100) NOT NULL,
    tp_comida VARCHAR2(50) NOT NULL,
    hr_funcionamento_restaurante VARCHAR2(50) NOT NULL,
    faixa_preco INTEGER NOT NULL,
    media_avaliacao NUMBER(2,1),
    CONSTRAINT FK_estacaoV6 FOREIGN KEY (id_estacao) REFERENCES T_ESTACAO,
    CONSTRAINT FK_ponto_turistico FOREIGN KEY (id_ponto_turistico) 
    REFERENCES T_PONTO_TURISTICO
)

ALTER TABLE T_ROTA
    ADD CONSTRAINT CK_estacao_inicial CHECK(estacao_inicial in ('LINHA 1-AZUL: JABAQUARA','LINHA 2-VERDE: VILA PRUDENTE','LINHA 3-VERMELHA: CORINTHIANS-ITAQUERA','LINHA 4-AMARELA: SÃO PAULO-MORUMBI','LINHA 5-LILÁS: CAPÃO REDONDO','LINHA 15-PRATA(MONOTRILHO): VILA PRUDENTE')) 
    ADD CONSTRAINT CK_estacao_final CHECK(estacao_final in ('LINHA 1-AZUL: TUCURUVI','LINHA 2-VERDE: VILA MADALENA','LINHA 3-VERMELHA: PALMEIRAS-BARRAFUNDA','LINHA 4-AMARELA: LUZ','LINHA 5-LILÁS: CHÁCARA KLABIN','LINHA 15-PRATA(MONOTRILHO): JARDIM COLONIAL')) 


DROP TABLE T_RESTAURANTE

DROP TABLE T_PONTO_TURISTICO

DROP TABLE T_ROTA

DROP TABLE T_SERVICO_METRO

DROP TABLE T_TOTEM

DROP TABLE T_CHATBOT

DROP TABLE T_ESTACAO

DROP TABLE T_COORDENADA

DROP TABLE T_USUARIO 

'''
Alexis Ronaldo Quirijota Rondo  RM: 560384
Lucas Gomes de Araujo Lopes  RM: 559607
Lucas Aurelio de Brito Chicote  RM: 559366
'''