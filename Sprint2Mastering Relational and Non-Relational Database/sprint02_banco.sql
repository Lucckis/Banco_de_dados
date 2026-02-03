------------------------------------------
-- Funções de verificação
------------------------------------------
CREATE OR REPLACE FUNCTION fn_valida_email_usuario (
    p_email IN VARCHAR2
) RETURN BOOLEAN IS
    v_contador NUMBER;
BEGIN
    IF INSTR(p_email, '@') = 0 OR INSTR(p_email, '.') = 0 THEN
        DBMS_OUTPUT.PUT_LINE('E-mail inválido.');
        RETURN FALSE;
    END IF;

    -- Verifica duplicidade no banco
    SELECT COUNT(*) INTO v_contador
    FROM T_USUARIO
    WHERE email = p_email;

    IF v_contador > 0 THEN
        DBMS_OUTPUT.PUT_LINE('E-mail já cadastrado.');
        RETURN FALSE;
    END IF;

    DBMS_OUTPUT.PUT_LINE('E-mail válido e disponível.');
    RETURN TRUE;
END;
/

CREATE OR REPLACE FUNCTION fn_valida_produto (
    p_valor IN NUMBER,
    p_qtde IN NUMBER,
    p_dt_validade IN DATE,
    p_id_estab IN NUMBER
) RETURN BOOLEAN IS
    v_existe NUMBER;
BEGIN
    IF p_valor <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Valor do produto inválido.');
        RETURN FALSE;
    END IF;

    IF p_qtde <= 0 THEN
        DBMS_OUTPUT.PUT_LINE('Quantidade deve ser maior que zero.');
        RETURN FALSE;
    END IF;

    IF p_dt_validade <= SYSDATE THEN
        DBMS_OUTPUT.PUT_LINE('Data de validade deve ser futura.');
        RETURN FALSE;
    END IF;

    SELECT COUNT(*) INTO v_existe
    FROM T_ESTABELECIMENTO
    WHERE id_estabelecimento = p_id_estab;

    IF v_existe = 0 THEN
        DBMS_OUTPUT.PUT_LINE('Estabelecimento não encontrado.');
        RETURN FALSE;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Produto válido para cadastro.');
    RETURN TRUE;
END;
/

--------------------------
-- PROCEDURES CRUD
--------------------------

-- T_ESTABELECIMENTO
CREATE OR REPLACE PROCEDURE sp_crud_estabelecimento (
    p_operacao IN VARCHAR2,
    p_id_estabelecimento IN NUMBER,
    p_nm_estabelecimento IN VARCHAR2 DEFAULT NULL,
    p_cnpj IN NUMBER DEFAULT NULL,
    p_endereco IN VARCHAR2 DEFAULT NULL,
    p_tel IN NUMBER DEFAULT NULL,
    p_tp_estabelecimento IN VARCHAR2 DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    IF p_operacao = 'I' THEN
        INSERT INTO T_ESTABELECIMENTO
        VALUES (p_id_estabelecimento, p_nm_estabelecimento, p_cnpj, p_endereco, p_tel, p_tp_estabelecimento);
        DBMS_OUTPUT.PUT_LINE('Estabelecimento inserido.');
        COMMIT;

    ELSIF p_operacao = 'U' THEN
        UPDATE T_ESTABELECIMENTO
        SET nm_estabelecimento = NVL(p_nm_estabelecimento, nm_estabelecimento),
            cnpj = NVL(p_cnpj, cnpj),
            endereco_estabelecimento = NVL(p_endereco, endereco_estabelecimento),
            tel_estabelecimento = NVL(p_tel, tel_estabelecimento),
            tp_estabelecimento = NVL(p_tp_estabelecimento, tp_estabelecimento)
        WHERE id_estabelecimento = p_id_estabelecimento;
        DBMS_OUTPUT.PUT_LINE('Estabelecimento atualizado.');
        COMMIT;

    ELSIF p_operacao = 'D' THEN
        DELETE FROM T_ESTABELECIMENTO WHERE id_estabelecimento = p_id_estabelecimento;
        DBMS_OUTPUT.PUT_LINE('Estabelecimento excluído.');
        COMMIT;

    ELSIF p_operacao = 'R' THEN
        IF p_id_estabelecimento IS NOT NULL THEN
            OPEN p_cursor FOR SELECT * FROM T_ESTABELECIMENTO WHERE id_estabelecimento = p_id_estabelecimento;
        ELSE
            OPEN p_cursor FOR SELECT * FROM T_ESTABELECIMENTO;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Consulta de estabelecimentos executada.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro sp_crud_estabelecimento: ' || SQLERRM);
        ROLLBACK;
END;
/

-- T_USUARIO
CREATE OR REPLACE PROCEDURE sp_crud_usuario (
    p_operacao IN VARCHAR2,
    p_id_usuario IN NUMBER,
    p_nm_usuario IN VARCHAR2 DEFAULT NULL,
    p_email IN VARCHAR2 DEFAULT NULL,
    p_senha IN VARCHAR2 DEFAULT NULL,
    p_endereco IN VARCHAR2 DEFAULT NULL,
    p_tel_usuario IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    IF p_operacao = 'I' THEN
        IF fn_valida_email_usuario(p_email) THEN
            INSERT INTO T_USUARIO VALUES (p_id_usuario, p_nm_usuario, p_email, p_senha, p_endereco, p_tel_usuario);
            DBMS_OUTPUT.PUT_LINE('Usuário inserido.');
            COMMIT;
        END IF;

    ELSIF p_operacao = 'U' THEN
        IF p_email IS NOT NULL THEN
            IF NOT fn_valida_email_usuario(p_email, p_id_usuario) THEN
                RETURN;
            END IF;
        END IF;

        UPDATE T_USUARIO
        SET nm_usuario = NVL(p_nm_usuario, nm_usuario),
            email = NVL(p_email, email),
            senha = NVL(p_senha, senha),
            endereco_usuario = NVL(p_endereco, endereco_usuario),
            tel_usuario = NVL(p_tel_usuario, tel_usuario)
        WHERE id_usuario = p_id_usuario;
        DBMS_OUTPUT.PUT_LINE('Usuário atualizado.');
        COMMIT;

    ELSIF p_operacao = 'D' THEN
        DELETE FROM T_USUARIO WHERE id_usuario = p_id_usuario;
        DBMS_OUTPUT.PUT_LINE('Usuário excluído.');
        COMMIT;

    ELSIF p_operacao = 'R' THEN
        IF p_id_usuario IS NOT NULL THEN
            OPEN p_cursor FOR SELECT * FROM T_USUARIO WHERE id_usuario = p_id_usuario;
        ELSE
            OPEN p_cursor FOR SELECT * FROM T_USUARIO;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Consulta de usuários executada.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro sp_crud_usuario: ' || SQLERRM);
        ROLLBACK;
END;
/

-- T_PRODUTO
CREATE OR REPLACE PROCEDURE sp_crud_produto (
    p_operacao IN VARCHAR2,
    p_id_produto IN NUMBER,
    p_nm_produto IN VARCHAR2 DEFAULT NULL,
    p_ds_produto IN VARCHAR2 DEFAULT NULL,
    p_vl_produto IN NUMBER DEFAULT NULL,
    p_dt_validade IN DATE DEFAULT NULL,
    p_qt_produto IN NUMBER DEFAULT NULL,
    p_id_estabelecimento IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    IF p_operacao = 'I' THEN
        IF fn_valida_produto(p_vl_produto, p_qt_produto, p_dt_validade, p_id_estabelecimento) THEN
            INSERT INTO T_PRODUTO VALUES (p_id_produto, p_nm_produto, p_ds_produto, p_vl_produto, p_dt_validade, p_qt_produto, p_id_estabelecimento);
            DBMS_OUTPUT.PUT_LINE('Produto inserido.');
            COMMIT;
        END IF;

    ELSIF p_operacao = 'U' THEN
        UPDATE T_PRODUTO
        SET nm_produto = NVL(p_nm_produto, nm_produto),
            ds_produto = NVL(p_ds_produto, ds_produto),
            vl_produto = NVL(p_vl_produto, vl_produto),
            dt_validade = NVL(p_dt_validade, dt_validade),
            qt_produto = NVL(p_qt_produto, qt_produto),
            id_estabelecimento = NVL(p_id_estabelecimento, id_estabelecimento)
        WHERE id_produto = p_id_produto;
        DBMS_OUTPUT.PUT_LINE('Produto atualizado.');
        COMMIT;

    ELSIF p_operacao = 'D' THEN
        DELETE FROM T_PRODUTO WHERE id_produto = p_id_produto;
        DBMS_OUTPUT.PUT_LINE('Produto excluído.');
        COMMIT;

    ELSIF p_operacao = 'R' THEN
        IF p_id_produto IS NOT NULL THEN
            OPEN p_cursor FOR SELECT * FROM T_PRODUTO WHERE id_produto = p_id_produto;
        ELSE
            OPEN p_cursor FOR SELECT * FROM T_PRODUTO;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Consulta de produtos executada.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro sp_crud_produto: ' || SQLERRM);
        ROLLBACK;
END;
/

-- T_PEDIDO
CREATE OR REPLACE PROCEDURE sp_crud_pedido (
    p_operacao IN VARCHAR2,
    p_id_pedido IN NUMBER,
    p_dt_hr_pedido IN DATE DEFAULT NULL,
    p_vl_total IN NUMBER DEFAULT NULL,
    p_st_pedido IN NUMBER DEFAULT NULL,
    p_id_usuario IN NUMBER DEFAULT NULL,
    p_id_estabelecimento IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    IF p_operacao = 'I' THEN
        INSERT INTO T_PEDIDO VALUES (p_id_pedido, NVL(p_dt_hr_pedido, SYSDATE), p_vl_total, p_st_pedido, p_id_usuario, p_id_estabelecimento);
        DBMS_OUTPUT.PUT_LINE('Pedido inserido.');
        COMMIT;

    ELSIF p_operacao = 'U' THEN
        UPDATE T_PEDIDO
        SET dt_hr_pedido = NVL(p_dt_hr_pedido, dt_hr_pedido),
            vl_total = NVL(p_vl_total, vl_total),
            st_pedido = NVL(p_st_pedido, st_pedido),
            id_usuario = NVL(p_id_usuario, id_usuario),
            id_estabelecimento = NVL(p_id_estabelecimento, id_estabelecimento)
        WHERE id_pedido = p_id_pedido;
        DBMS_OUTPUT.PUT_LINE('Pedido atualizado.');
        COMMIT;

    ELSIF p_operacao = 'D' THEN
        DELETE FROM T_PEDIDO WHERE id_pedido = p_id_pedido;
        DBMS_OUTPUT.PUT_LINE('Pedido excluído.');
        COMMIT;

    ELSIF p_operacao = 'R' THEN
        IF p_id_pedido IS NOT NULL THEN
            OPEN p_cursor FOR SELECT * FROM T_PEDIDO WHERE id_pedido = p_id_pedido;
        ELSE
            OPEN p_cursor FOR SELECT * FROM T_PEDIDO;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Consulta de pedidos executada.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro sp_crud_pedido: ' || SQLERRM);
        ROLLBACK;
END;
/

-- T_ITEM_PEDIDO
CREATE OR REPLACE PROCEDURE sp_crud_item_pedido (
    p_operacao IN VARCHAR2,
    p_id_item IN NUMBER,
    p_qt_item IN NUMBER DEFAULT NULL,
    p_id_pedido IN NUMBER DEFAULT NULL,
    p_id_produto IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    IF p_operacao = 'I' THEN
        INSERT INTO T_ITEM_PEDIDO VALUES (p_id_item, p_qt_item, p_id_pedido, p_id_produto);
        DBMS_OUTPUT.PUT_LINE('Item inserido.');
        COMMIT;

    ELSIF p_operacao = 'U' THEN
        UPDATE T_ITEM_PEDIDO
        SET qt_item = NVL(p_qt_item, qt_item),
            id_pedido = NVL(p_id_pedido, id_pedido),
            id_produto = NVL(p_id_produto, id_produto)
        WHERE id_item = p_id_item;
        DBMS_OUTPUT.PUT_LINE('Item atualizado.');
        COMMIT;

    ELSIF p_operacao = 'D' THEN
        DELETE FROM T_ITEM_PEDIDO WHERE id_item = p_id_item;
        DBMS_OUTPUT.PUT_LINE('Item excluído.');
        COMMIT;

    ELSIF p_operacao = 'R' THEN
        IF p_id_item IS NOT NULL THEN
            OPEN p_cursor FOR SELECT * FROM T_ITEM_PEDIDO WHERE id_item = p_id_item;
        ELSE
            OPEN p_cursor FOR SELECT * FROM T_ITEM_PEDIDO;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Consulta de itens de pedido executada.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro sp_crud_item_pedido: ' || SQLERRM);
        ROLLBACK;
END;
/

-- T_PAGAMENTO
CREATE OR REPLACE PROCEDURE sp_crud_pagamento (
    p_operacao IN VARCHAR2,
    p_id_pagamento IN NUMBER,
    p_forma_pagamento IN VARCHAR2 DEFAULT NULL,
    p_vl_pagamento IN NUMBER DEFAULT NULL,
    p_st_pagamento IN NUMBER DEFAULT NULL,
    p_id_pedido IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    IF p_operacao = 'I' THEN
        INSERT INTO T_PAGAMENTO VALUES (p_id_pagamento, p_forma_pagamento, p_vl_pagamento, p_st_pagamento, p_id_pedido);
        DBMS_OUTPUT.PUT_LINE('Pagamento inserido.');
        COMMIT;

    ELSIF p_operacao = 'U' THEN
        UPDATE T_PAGAMENTO
        SET forma_pagamento = NVL(p_forma_pagamento, forma_pagamento),
            vl_pagamento = NVL(p_vl_pagamento, vl_pagamento),
            st_pagamento = NVL(p_st_pagamento, st_pagamento),
            id_pedido = NVL(p_id_pedido, id_pedido)
        WHERE id_pagamento = p_id_pagamento;
        DBMS_OUTPUT.PUT_LINE('Pagamento atualizado.');
        COMMIT;

    ELSIF p_operacao = 'D' THEN
        DELETE FROM T_PAGAMENTO WHERE id_pagamento = p_id_pagamento;
        DBMS_OUTPUT.PUT_LINE('Pagamento excluído.');
        COMMIT;

    ELSIF p_operacao = 'R' THEN
        IF p_id_pagamento IS NOT NULL THEN
            OPEN p_cursor FOR SELECT * FROM T_PAGAMENTO WHERE id_pagamento = p_id_pagamento;
        ELSE
            OPEN p_cursor FOR SELECT * FROM T_PAGAMENTO;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Consulta de pagamentos executada.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro sp_crud_pagamento: ' || SQLERRM);
        ROLLBACK;
END;
/

-- T_CUPOM
CREATE OR REPLACE PROCEDURE sp_crud_cupom (
    p_operacao IN VARCHAR2,
    p_id_cupom IN NUMBER,
    p_vl_cupom IN NUMBER DEFAULT NULL,
    p_id_usuario IN NUMBER DEFAULT NULL,
    p_cursor OUT SYS_REFCURSOR
) AS
BEGIN
    IF p_operacao = 'I' THEN
        INSERT INTO T_CUPOM VALUES (p_id_cupom, p_vl_cupom, p_id_usuario);
        DBMS_OUTPUT.PUT_LINE('Cupom inserido.');
        COMMIT;

    ELSIF p_operacao = 'U' THEN
        UPDATE T_CUPOM
        SET vl_cupom = NVL(p_vl_cupom, vl_cupom),
            id_usuario = NVL(p_id_usuario, id_usuario)
        WHERE id_cupom = p_id_cupom;
        DBMS_OUTPUT.PUT_LINE('Cupom atualizado.');
        COMMIT;

    ELSIF p_operacao = 'D' THEN
        DELETE FROM T_CUPOM WHERE id_cupom = p_id_cupom;
        DBMS_OUTPUT.PUT_LINE('Cupom excluído.');
        COMMIT;

    ELSIF p_operacao = 'R' THEN
        IF p_id_cupom IS NOT NULL THEN
            OPEN p_cursor FOR SELECT * FROM T_CUPOM WHERE id_cupom = p_id_cupom;
        ELSE
            OPEN p_cursor FOR SELECT * FROM T_CUPOM;
        END IF;
        DBMS_OUTPUT.PUT_LINE('Consulta de cupons executada.');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        DBMS_OUTPUT.PUT_LINE('Erro sp_crud_cupom: ' || SQLERRM);
        ROLLBACK;
END;
/

----------------------------------
--Função para relatórios
----------------------------------

CREATE OR REPLACE TYPE tp_relatorio_pedido AS OBJECT (
    nm_usuario VARCHAR2(100),
    nm_estabelecimento VARCHAR2(50),
    dt_hr_pedido DATE,
    vl_total NUMBER,
    st_pedido VARCHAR2(20)
);
/

CREATE OR REPLACE TYPE tb_relatorio_pedido AS TABLE OF tp_relatorio_pedido;
/

CREATE OR REPLACE FUNCTION fn_relatorio_pedidos
RETURN tb_relatorio_pedido
PIPELINED
IS
    CURSOR c_pedidos IS
        SELECT 
            u.nm_usuario,
            e.nm_estabelecimento,
            p.dt_hr_pedido,
            p.vl_total,
            CASE p.st_pedido 
                WHEN 0 THEN 'Não pronto'
                WHEN 1 THEN 'Pronto'
            END AS status_pedido
        FROM T_PEDIDO p
        INNER JOIN T_USUARIO u ON p.id_usuario = u.id_usuario
        INNER JOIN T_ESTABELECIMENTO e ON p.id_estabelecimento = e.id_estabelecimento
        ORDER BY p.dt_hr_pedido DESC;
BEGIN
    FOR r IN c_pedidos LOOP
        PIPE ROW (tp_relatorio_pedido(
            r.nm_usuario,
            r.nm_estabelecimento,
            r.dt_hr_pedido,
            r.vl_total,
            r.status_pedido
        ));
    END LOOP;
    RETURN;
END;
/

------------------------------------------------
-- Relatório com regra de negócio
------------------------------------------------

CREATE OR REPLACE TYPE tp_relatorio_gasto_usuario AS OBJECT (
    nm_usuario VARCHAR2(100),
    qtd_pedidos NUMBER,
    total_gasto NUMBER
);
/

CREATE OR REPLACE TYPE tb_relatorio_gasto_usuario AS TABLE OF tp_relatorio_gasto_usuario;
/

CREATE OR REPLACE FUNCTION fn_relatorio_gasto_usuario
RETURN tb_relatorio_gasto_usuario
PIPELINED
IS
    CURSOR c_relatorio IS
        SELECT 
            u.nm_usuario,
            COUNT(p.id_pedido) AS qtd_pedidos,
            SUM(p.vl_total) AS total_gasto
        FROM T_USUARIO u
        INNER JOIN T_PEDIDO p ON u.id_usuario = p.id_usuario
        GROUP BY u.nm_usuario
        ORDER BY total_gasto DESC;
BEGIN
    FOR r IN c_relatorio LOOP
        PIPE ROW (tp_relatorio_gasto_usuario(
            r.nm_usuario,
            r.qtd_pedidos,
            r.total_gasto
        ));
    END LOOP;

    RETURN;
END;
/






















