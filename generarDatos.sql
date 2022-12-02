/* Creacion de tablas */
DROP TABLE detalle;
/
DROP TABLE factura;
/

CREATE TABLE factura(
    codigof NUMBER(20) PRIMARY KEY,
    fecha DATE NOT NULL
);
/

CREATE TABLE detalle(
    codigod NUMBER(20) PRIMARY KEY,
    codproducto NUMBER(20) NOT NULL,
    nro_unidades NUMBER(20) NOT NULL,
    valor_unitario NUMBER(20) NOT NULL,
    codfact NUMBER(20) NOT NULL REFERENCES factura
);
/

/* Procedimiento llenado aleatorio factura PL/SQL */

CREATE OR REPLACE PROCEDURE llenado_aleatorio_factura
(nro_entradas IN NUMBER) IS
codigof_n NUMBER(20);
fecha_rand DATE;
controlador NUMBER(2);
BEGIN
    FOR cont IN 1..nro_entradas
    LOOP
        SELECT dbms_random.value(1,999999999999999999) into codigof_n FROM dual;
        SELECT COUNT(*) INTO controlador FROM factura WHERE codigof = codigof_n;
        WHILE controlador <> 0
        LOOP
            SELECT dbms_random.value(1,999999999999999999) into codigof_n FROM dual;
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
    CURSOR cursor_codfact IS SELECT codigof FROM factura;
    controlador NUMBER(10);
BEGIN
    SELECT COUNT(*) INTO controlador FROM detalle;
    OPEN cursor_codfact;
    FOR cont IN 1..nro_entradas
        LOOP
            FETCH cursor_codfact INTO codfact_n;
            IF cursor_codfact%NOTFOUND THEN
                CLOSE cursor_codfact;
                OPEN cursor_codfact;
                FETCH cursor_codfact INTO codfact_n;
            END IF;
            SELECT COUNT(*) INTO controlador FROM detalle WHERE codfact = codfact_n;
            WHILE controlador >= maxDetalles
                LOOP
                    FETCH cursor_codfact INTO codfact_n;
                    EXIT WHEN cursor_codfact%NOTFOUND;
                    SELECT COUNT(*) INTO controlador FROM detalle WHERE codfact = codfact_n;
                END LOOP;

            IF cursor_codfact%NOTFOUND THEN
                CONTINUE;
            end if;

            SELECT dbms_random.value(1,999999999999999999) into codigod_n FROM dual;
            SELECT COUNT(*) INTO controlador FROM detalle WHERE codigod = codigod_n;
            WHILE controlador <> 0
                LOOP
                    SELECT dbms_random.value(1,999999999999999999) into codigod_n FROM dual;
                    SELECT COUNT(*) INTO controlador FROM detalle WHERE codigod = codigod_n;
                END LOOP;

            SELECT dbms_random.value(1,999999999999999999) into codproducto_n FROM dual;
            SELECT dbms_random.value(1,999999999999999999) into nro_unidades_n FROM dual;
            SELECT dbms_random.value(1,999999999999999999) into valor_unitario_n FROM dual;

            INSERT INTO detalle VALUES (codigod_n, codproducto_n, nro_unidades_n, valor_unitario_n, codfact_n);
        END LOOP;
END;
/

/* -------------------------------------------------------*/
/* Primer experimento */
/* -------------------------------------------------------*/

/* Pocos datos */
/* -------------------------------------------------------*/

/* Limpiar las tablas */
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

/* Llenar las tablas con pocos datos */
EXEC llenado_aleatorio_factura(5000);
EXEC llenado_aleatorio_detalle(20000, 7);

/* A */
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* B */
CREATE INDEX i_codfact ON detalle(codfact);
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* C */
DROP CLUSTER factCluster;
DROP INDEX i_factCluster;
CREATE CLUSTER factCluster (codi_fact NUMBER(20));
CREATE INDEX i_factCluster ON CLUSTER factCluster;

/* Limpiar las tablas y crearlas en el cluster */
DROP TABLE detalle;
DROP TABLE factura;
CREATE TABLE factura(
    codigof NUMBER(20) PRIMARY KEY,
    fecha DATE NOT NULL
    ) CLUSTER factCluster(codigof);

CREATE TABLE detalle(
    codigod NUMBER(20) PRIMARY KEY,
    codproducto NUMBER(20) NOT NULL,
    nro_unidades NUMBER(20) NOT NULL,
    valor_unitario NUMBER(20) NOT NULL,
    codfact NUMBER(20) NOT NULL REFERENCES factura
    ) CLUSTER factCluster(codfact);

/* Llenar las tablas con pocos datos */
EXEC llenado_aleatorio_factura(5000);
EXEC llenado_aleatorio_detalle(20000, 7);

/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* D */
/* Limpiar las tablas */
DROP TABLE detalle;
DROP TABLE factura;

/* Creacion de las tablas de forma objeto relacional */
CREATE TYPE factura AS OBJECT(
     codigof NUMBER(20),
     fecha DATE
);

CREATE TYPE detalle AS OBJECT(
    codigod NUMBER(20),
    codproducto NUMBER(20),
    nro_unidades NUMBER(20),
    valor_unitario NUMBER(20),
    dfactura REF factura
);

/* Llenar las tablas con pocos datos */
EXEC llenado_aleatorio_factura(5000);
EXEC llenado_aleatorio_detalle(20000, 7);

/* Ejecutamos la consulta */
SELECT * FROM detalle;

/* Muchos datos */
/* -------------------------------------------------------*/

/* Limpiar las tablas */
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

/* Llenar las tablas con muchos datos */
EXEC llenado_aleatorio_factura(25000);
EXEC llenado_aleatorio_detalle(100000, 7);

/* A */
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* B */
CREATE INDEX i_codfact ON detalle(codfact);
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* C */
DROP CLUSTER factCluster;
DROP INDEX i_factCluster;
CREATE CLUSTER factCluster (codi_fact NUMBER(20));
CREATE INDEX i_factCluster ON CLUSTER factCluster;

/* Limpiar las tablas y crearlas en el cluster */
DROP TABLE detalle;
DROP TABLE factura;
CREATE TABLE factura(
                        codigof NUMBER(20) PRIMARY KEY,
                        fecha DATE NOT NULL
) CLUSTER factCluster(codigof);

CREATE TABLE detalle(
                        codigod NUMBER(20) PRIMARY KEY,
                        codproducto NUMBER(20) NOT NULL,
                        nro_unidades NUMBER(20) NOT NULL,
                        valor_unitario NUMBER(20) NOT NULL,
                        codfact NUMBER(20) NOT NULL REFERENCES factura
) CLUSTER factCluster(codfact);

/* Llenar las tablas con muchos */
EXEC llenado_aleatorio_factura(25000);
EXEC llenado_aleatorio_detalle(100000, 7);

/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* D */
/* Limpiar las tablas */
DROP TABLE detalle;
DROP TABLE factura;

/* Creacion de las tablas de forma objeto relacional */
CREATE TYPE factura AS OBJECT(
                                 codigof NUMBER(20),
                                 fecha DATE
                             );

CREATE TYPE detalle AS OBJECT(
                                 codigod NUMBER(20),
                                 codproducto NUMBER(20),
                                 nro_unidades NUMBER(20),
                                 valor_unitario NUMBER(20),
                                 dfactura REF factura
                             );

/* Llenar las tablas con muchos datos */
EXEC llenado_aleatorio_factura(25000);
EXEC llenado_aleatorio_detalle(100000, 7);

/* Ejecutamos la consulta */
SELECT * FROM detalle;

/* -------------------------------------------------------*/
/* Segundo experimento */
/* -------------------------------------------------------*/

/* Pocos datos */
/* -------------------------------------------------------*/

/* Limpiar las tablas */
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

/* Llenar las tablas con pocos datos */
EXEC llenado_aleatorio_factura(5000);
EXEC llenado_aleatorio_detalle(10000, 3);

/* A */
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* B */
CREATE INDEX i_codfact ON detalle(codfact);
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* C */
DROP CLUSTER factCluster;
DROP INDEX i_factCluster;
CREATE CLUSTER factCluster (codi_fact NUMBER(20));
CREATE INDEX i_factCluster ON CLUSTER factCluster;

/* Limpiar las tablas y crearlas en el cluster */
DROP TABLE detalle;
DROP TABLE factura;
CREATE TABLE factura(
                        codigof NUMBER(20) PRIMARY KEY,
                        fecha DATE NOT NULL
) CLUSTER factCluster(codigof);

CREATE TABLE detalle(
                        codigod NUMBER(20) PRIMARY KEY,
                        codproducto NUMBER(20) NOT NULL,
                        nro_unidades NUMBER(20) NOT NULL,
                        valor_unitario NUMBER(20) NOT NULL,
                        codfact NUMBER(20) NOT NULL REFERENCES factura
) CLUSTER factCluster(codfact);

/* Llenar las tablas con pocos datos */
EXEC llenado_aleatorio_factura(5000);
EXEC llenado_aleatorio_detalle(10000, 3);

/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* D */
/* Limpiar las tablas */
DROP TABLE detalle;
DROP TABLE factura;

/* Creacion de las tablas de forma objeto relacional */
CREATE TYPE factura AS OBJECT(
                                 codigof NUMBER(20),
                                 fecha DATE
                             );

CREATE TYPE detalle AS OBJECT(
                                 codigod NUMBER(20),
                                 codproducto NUMBER(20),
                                 nro_unidades NUMBER(20),
                                 valor_unitario NUMBER(20),
                                 dfactura REF factura
                             );

/* Llenar las tablas con pocos datos */
EXEC llenado_aleatorio_factura(5000);
EXEC llenado_aleatorio_detalle(10000, 3);

/* Ejecutamos la consulta */
SELECT * FROM detalle;

/* Muchos datos */
/* -------------------------------------------------------*/

/* Limpiar las tablas */
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

/* Llenar las tablas con muchos datos */
EXEC llenado_aleatorio_factura(50000);
EXEC llenado_aleatorio_detalle(100000, 3);

/* A */
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* B */
CREATE INDEX i_codfact ON detalle(codfact);
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* C */
DROP CLUSTER factCluster;
DROP INDEX i_factCluster;
CREATE CLUSTER factCluster (codi_fact NUMBER(20));
CREATE INDEX i_factCluster ON CLUSTER factCluster;

/* Limpiar las tablas y crearlas en el cluster */
DROP TABLE detalle;
DROP TABLE factura;
CREATE TABLE factura(
                        codigof NUMBER(20) PRIMARY KEY,
                        fecha DATE NOT NULL
) CLUSTER factCluster(codigof);

CREATE TABLE detalle(
                        codigod NUMBER(20) PRIMARY KEY,
                        codproducto NUMBER(20) NOT NULL,
                        nro_unidades NUMBER(20) NOT NULL,
                        valor_unitario NUMBER(20) NOT NULL,
                        codfact NUMBER(20) NOT NULL REFERENCES factura
) CLUSTER factCluster(codfact);

/* Llenar las tablas con muchos */
EXEC llenado_aleatorio_factura(50000);
EXEC llenado_aleatorio_detalle(100000, 3);

/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* D */
/* Limpiar las tablas */
DROP TABLE detalle;
DROP TABLE factura;

/* Creacion de las tablas de forma objeto relacional */
CREATE TYPE factura AS OBJECT(
                                 codigof NUMBER(20),
                                 fecha DATE
                             );

CREATE TYPE detalle AS OBJECT(
                                 codigod NUMBER(20),
                                 codproducto NUMBER(20),
                                 nro_unidades NUMBER(20),
                                 valor_unitario NUMBER(20),
                                 dfactura REF factura
                             );

/* Llenar las tablas con muchos datos */
EXEC llenado_aleatorio_factura(50000);
EXEC llenado_aleatorio_detalle(100000, 3);

/* Ejecutamos la consulta */
SELECT * FROM detalle;

/* -------------------------------------------------------*/
/* Tercer experimento  */
/* -------------------------------------------------------*/

/* Pocos datos */
/* -------------------------------------------------------*/

/* Limpiar las tablas */
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

/* Llenar las tablas con pocos datos */
EXEC llenado_aleatorio_factura(5000);
EXEC llenado_aleatorio_detalle(5000, 1);

/* A */
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* B */
CREATE INDEX i_codfact ON detalle(codfact);
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* C */
DROP CLUSTER factCluster;
DROP INDEX i_factCluster;
CREATE CLUSTER factCluster (codi_fact NUMBER(20));
CREATE INDEX i_factCluster ON CLUSTER factCluster;

/* Limpiar las tablas y crearlas en el cluster */
DROP TABLE detalle;
DROP TABLE factura;
CREATE TABLE factura(
                        codigof NUMBER(20) PRIMARY KEY,
                        fecha DATE NOT NULL
) CLUSTER factCluster(codigof);

CREATE TABLE detalle(
                        codigod NUMBER(20) PRIMARY KEY,
                        codproducto NUMBER(20) NOT NULL,
                        nro_unidades NUMBER(20) NOT NULL,
                        valor_unitario NUMBER(20) NOT NULL,
                        codfact NUMBER(20) NOT NULL REFERENCES factura
) CLUSTER factCluster(codfact);

/* Llenar las tablas con pocos datos */
EXEC llenado_aleatorio_factura(5000);
EXEC llenado_aleatorio_detalle(5000, 1);

/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* D */
/* Limpiar las tablas */
DROP TABLE detalle;
DROP TABLE factura;

/* Creacion de las tablas de forma objeto relacional */
CREATE TYPE factura AS OBJECT(
                                 codigof NUMBER(20),
                                 fecha DATE
                             );

CREATE TYPE detalle AS OBJECT(
                                 codigod NUMBER(20),
                                 codproducto NUMBER(20),
                                 nro_unidades NUMBER(20),
                                 valor_unitario NUMBER(20),
                                 dfactura REF factura
                             );

/* Llenar las tablas con pocos datos */
EXEC llenado_aleatorio_factura(5000);
EXEC llenado_aleatorio_detalle(5000, 1);

/* Ejecutamos la consulta */
SELECT * FROM detalle;

/* Muchos datos */
/* -------------------------------------------------------*/

/* Limpiar las tablas */
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

/* Llenar las tablas con muchos datos */
EXEC llenado_aleatorio_factura(50000);
EXEC llenado_aleatorio_detalle(50000, 1);

/* A */
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* B */
CREATE INDEX i_codfact ON detalle(codfact);
/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* C */
DROP CLUSTER factCluster;
DROP INDEX i_factCluster;
CREATE CLUSTER factCluster (codi_fact NUMBER(20));
CREATE INDEX i_factCluster ON CLUSTER factCluster;

/* Limpiar las tablas y crearlas en el cluster */
DROP TABLE detalle;
DROP TABLE factura;
CREATE TABLE factura(
                        codigof NUMBER(20) PRIMARY KEY,
                        fecha DATE NOT NULL
) CLUSTER factCluster(codigof);

CREATE TABLE detalle(
                        codigod NUMBER(20) PRIMARY KEY,
                        codproducto NUMBER(20) NOT NULL,
                        nro_unidades NUMBER(20) NOT NULL,
                        valor_unitario NUMBER(20) NOT NULL,
                        codfact NUMBER(20) NOT NULL REFERENCES factura
) CLUSTER factCluster(codfact);

/* Llenar las tablas con muchos */
EXEC llenado_aleatorio_factura(50000);
EXEC llenado_aleatorio_detalle(50000, 1);

/* Ejecutamos la consulta */
SELECT * FROM factura f, detalle d WHERE f.codigof = d.codfact;

/* D */
/* Limpiar las tablas */
DROP TABLE detalle;
DROP TABLE factura;

/* Creacion de las tablas de forma objeto relacional */
CREATE TYPE factura AS OBJECT(
                                 codigof NUMBER(20),
                                 fecha DATE
                             );

CREATE TYPE detalle AS OBJECT(
                                 codigod NUMBER(20),
                                 codproducto NUMBER(20),
                                 nro_unidades NUMBER(20),
                                 valor_unitario NUMBER(20),
                                 dfactura REF factura
                             );

/* Llenar las tablas con muchos datos */
EXEC llenado_aleatorio_factura(50000);
EXEC llenado_aleatorio_detalle(50000, 1);

/* Ejecutamos la consulta */
SELECT * FROM detalle;