/* Creacion de tablas */
DROP TABLE detalle;
DROP TABLE factura;

CREATE TABLE factura(
    codigof NUMBER(20) PRIMARY KEY,
    fecha DATE NOT NULL
    );

CREATE TABLE detalle(
    codigod NUMBER(20) PRIMARY KEY,
    codproducto NUMBER(20) NOT NULL,
    nro_unidades NUMBER(20) NOT NULL,
    valor_unitario NUMBER(20) NOT NULL,
    codfact NUMBER(20) NOT NULL REFERENCES factura
);

/* Procedimiento llenado aleatorio factura PL/SQL */

CREATE OR REPLACE PROCEDURE llenado_aleatorio_factura
(nro_entradas IN NUMBER) IS
codigof_n NUMBER(20);
fecha_rand DATE;
controlador NUMBER(2);
BEGIN
    FOR cont IN 1..nro_entradas
    LOOP
        SELECT dbms_random.value(1,99999999999999999999) into codigof_n FROM dual;
        SELECT COUNT(*) INTO controlador FROM factura WHERE codigof = codigof_n;
        WHILE controlador <> 0
        LOOP
            SELECT dbms_random.value(1,99999999999999999999) into codigof_n FROM dual;
            SELECT COUNT(*) INTO controlador FROM factura WHERE codigof = codigof_n;
        END LOOP;

        SELECT TO_DATE(
                TRUNC(
                    DBMS_RANDOM.VALUE(TO_CHAR(DATE '1950-01-01','J')
                                      ,TO_CHAR(DATE '2022-12-31','J')
                                     )
                    ),'J'
                ) INTO fecha_rand FROM DUAL;
        INSERT INTO factura VALUES (codigof_n, fecha_rand);
    END LOOP;
END;
/

/* Procedimiento llenado aleatorio detalle PL/SQL */
/* ADVERTENCIA: para generar 100000 valores o mas puede exceder el tiempo limite de ejecucion */

CREATE OR REPLACE PROCEDURE llenado_aleatorio_detalle
(nro_entradas IN NUMBER, maxDetalles IN NUMBER) IS
    codigod_n NUMBER(20);
    codproducto_n NUMBER(20);
    nro_unidades_n NUMBER(20);
    valor_unitario_n NUMBER(20);
    codfact_n NUMBER(20);
    controlador NUMBER(2);
BEGIN
    FOR cont IN 1..nro_entradas
        LOOP
            SELECT dbms_random.value(1,99999999999999999999) into codigod_n FROM dual;
            SELECT COUNT(*) INTO controlador FROM detalle WHERE codigod = codigod_n;
            WHILE controlador <> 0
                LOOP
                    SELECT dbms_random.value(1,99999999999999999999) into codigod_n FROM dual;
                    SELECT COUNT(*) INTO controlador FROM detalle WHERE codigod = codigod_n;
                END LOOP;

            SELECT codigof into codfact_n FROM factura ORDER BY dbms_random.value FETCH FIRST 1 ROWS ONLY;
            SELECT COUNT(*) INTO controlador FROM detalle WHERE codfact = codfact_n;
            WHILE controlador >= maxDetalles
                LOOP
                    SELECT codigof into codfact_n FROM factura ORDER BY dbms_random.value FETCH FIRST 1 ROWS ONLY;
                    SELECT COUNT(*) INTO controlador FROM detalle WHERE codfact = codfact_n;
                END LOOP;

            SELECT dbms_random.value(1,99999999999999999999) into codproducto_n FROM dual;
            SELECT dbms_random.value(1,99999999999999999999) into nro_unidades_n FROM dual;
            SELECT dbms_random.value(1,99999999999999999999) into valor_unitario_n FROM dual;

            INSERT INTO detalle VALUES (codigod_n, codproducto_n, nro_unidades_n, valor_unitario_n, codfact_n);
        END LOOP;
END;
/